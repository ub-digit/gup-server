class Guresearch::GeneralController < ApplicationController

  def solr
    @@rsolr ||= RSolr.connect(url: APP_CONFIG['gu_reasearch_index_url'])
  end

  def list_publications
    svepid =        params[:svepid] || ''
    catid =         params[:catid] || ''
    userid =        params[:userid] || ''
    departmentid =  params[:departmentid] || ''
    palassoid =     params[:palassoid] || ''

    lyear =         params[:lyear] || '1900'
    hyear =         params[:hyear] || '9999'
    spost =         params[:spost] || '0'
    npost =         params[:npost] || '0'

    fq = []
    if svepid.present? 
      fq.push('svepid:' + svepid + '*')
      facet_field = "person_last_first_extid_mapping"
    elsif catid.present? 
      fq.push("category_id:" + catid)
      facet_field = "person_last_first_extid_mapping"
    elsif userid.present? 
      fq.push("person_extid:" + userid)
      facet_field = "category_mapping_sv_en"
    elsif departmentid.present? 
      fq.push('department_id:' + departmentid)
      facet_field = "category_mapping_sv_en"
    elsif palassoid.present? 
      fq.push("palassoid:" + palassoid)
      facet_field = "category_mapping_sv_en"
    else
      render nothing: true
      return
    end

    fq.push("pubyear:[" + lyear + " TO " + hyear + "]")
    sort = "pubyear desc"

    response_docs = solr.paginate spost.to_i, npost.to_i, 'select', :params => {:q => "*:*", :fq => fq, :wt=> 'xml', :sort => sort}
    publications = Nokogiri::XML(response_docs)

    response_counts = solr.paginate 0, 0, 'select', :params => {:q => "*:*",
                                                                :fq => fq, 
                                                                :wt=> 'json', 
                                                                facet: true, 
                                                                "facet.field" => facet_field, 
                                                                "facet.mincount" => 1, 
                                                                "facet.limit" => -1, 
                                                                "facet.sort" => "count"}

    counts = response_counts["facet_counts"]["facet_fields"][facet_field]
    count_list = Hash[*counts]  

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.xmlpage do
        if facet_field.eql?("person_last_first_extid_mapping")
          xml.send(:"researchers") do
            count_list.each.with_index do |c, index|
              xml.send(:"researcher", "num" => "#{index + 1}") do
                parts = c[0].split(":")
                xml.personid parts[0]
                xml.last parts[1]
                xml.first parts[2]                
                xml.external_user_id parts[3]
                xml.publications c[1]
              end
            end
          end
        elsif facet_field.eql?("category_mapping_sv_en")
          xml.send(:"relatedcategories") do
            count_list.each.with_index do |c, index|
              xml.send(:"category", "num" => "#{index + 1}") do
                parts = c[0].split(":")
                xml.catid parts[0]
                xml.sv_name parts[1]
                xml.en_name parts[2]
                xml.antal c[1]
              end
            end
          end

        end
        xml << publications.root.to_s
      end
    end

    render xml: builder
  end
  
  # Returns all reachers in a category and its subcategories
  def list_researchers
    catid =         params[:catid] || ''

    lyear =         params[:lyear] || '1900'
    hyear =         params[:hyear] || '9999'
    spost =         params[:spost] || '0'
    npost =         params[:npost] || '-1'
    if catid.blank?
      render nothing: true
      return
    end      
    category_obj = Category.find_by_id(catid.to_i)
    if category_obj.blank?
      render nothing: true
      return
    end      

    svepid = category_obj.svepid

    sql_str = "SELECT p.id, p.last_name, p.first_name, p.year_of_birth, i.value, count(p.id) c, row_number() OVER () AS rnum
              FROM people p
              JOIN identifiers i ON i.person_id = p.id
              JOIN sources s ON s.id = i.source_id
              JOIN people2publications p2p ON p2p.person_id = p.id
              JOIN publication_versions pv ON pv.id = p2p.publication_version_id
              JOIN publications publ ON publ.current_version_id = pv.id
              JOIN categories2publications c2p ON c2p.publication_version_id = pv.id
              JOIN categories c ON c.id = c2p.category_id
              WHERE s.name = 'xkonto'
              AND publ.deleted_at IS NULL
              AND publ.published_at IS NOT NULL
              AND CAST(c.svepid AS text) LIKE '#{svepid}%'
              AND pv.pubyear >= #{lyear}
              AND pv.pubyear <= #{hyear}
              GROUP BY p.id, p.last_name, p.first_name, p.year_of_birth, i.value
              HAVING count(p.id) > 1
              ORDER BY p.last_name, p.first_name"

  person_list = Person.find_by_sql(sql_str)
  if person_list.blank?
    render nothing: true
    return
  end    
  person_list_sliced = (npost.to_i == -1) ? person_list[spost.to_i..-1] : person_list[spost.to_i, npost.to_i]
  if person_list_sliced.blank?
    render nothing: true
    return
  end    


  builder = Nokogiri::XML::Builder.new do |xml|
    xml.send(:"upl-records-researchers") do
      xml.send(:"upl-researchers") do
        person_list_sliced.each.with_index do |p, i|
          xml.send(:"upl-researchers", "num" => "#{i + 1}") do
            xml.rnum p.rnum
            xml.last p.last_name
            xml.first p.first_name
            xml.byear p.year_of_birth
            xml.external_user_id p.value
            xml.pubcount p.c
          end 
        end   
      end
    end
  end
  render xml: builder

  end
  
  # Performs a solr request
  def wrap_solr_request

    # Get fq parameters from request object
    fq =[]
    request.query_string.split("&").each do |p|
      if p.starts_with?("fq=")
        fq.push(URI.unescape(p[3..-1]))
      end
    end
    pp fq

    q  =    params[:q] || "*:*"
    wt =    params[:wt] || "json"
    start = params[:start] || 0
    rows =  params[:rows] || 10
    sort =  params[:sort] || 'pubid desc'


    response = solr.paginate start.to_i, rows.to_i, 'select', :params => {:q => q, :fq => fq, :wt=> wt, :sort => sort}
    pp response
    if wt.eql?("xml")
      render xml: response
    elsif wt.eql?("json")
      render json: response
    else
      render nothing: true
    end
  end



  def list_publications_special
    param_type = params[:param_type] || ''
    ids =        params[:ids] || ''
    lyear =      params[:lyear] || '1900'
    hyear =      params[:hyear] || '9999'
    
    if ids.present?
      fq = []
      fq_id = ''
      if param_type.eql?("departments")
        fq_id = 'department_id:'
        departments = Department.where(id: ids.split(",").map{ |id| id.to_i })
        pp departments
      elsif param_type.eql?("people")
        fq_id = 'person_id:'
        people = Person.where(id: ids.split(",").map{ |id| id.to_i })
        pp people
      elsif param_type.eql?("series")
        fq_id = 'serie_id:'
        series = Serie.where(id: ids.split(",").map{ |id| id.to_i })
        pp series
      else
        render nothing: true
        return
      end  
      fq.push(fq_id + '(' + ids.split(",").join(" OR ") + ')')
      fq.push("pubyear:[" + lyear + " TO " + hyear + "]")
    else
      render nothing: true
      return      
    end

    

    # Get number of hits
    response = solr.paginate 0, 0, 'select', :params => {:q => "*:*", :fq => fq, :wt=> 'json'}

    start = 0
    #rows = response["response"]["numFound"].to_i > 500 ? 500 : response["response"]["numFound"].to_i

    rows = response["response"]["numFound"].to_i
    sort = "pubyear desc"


    response = solr.paginate start, rows, 'select', :params => {:q => "*:*", :fq => fq, :wt=> 'json', :sort => sort}

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.send(:"upl-records-publications") do
        xml.send(:"header") do
          xml.url_prefix_detailed_record request.base_url + "/publications/show/"
        
          if param_type.eql?("departments")
            xml.send(:"requested_items") do
              departments.each.with_index do |d, i|
                xml.send(:"item", "num" => "#{i + 1}") do
                  xml.deptid d.id
                  xml.parentid d.parentid
                  xml.sv_name d.name_sv
                  xml.en_name d.name_en
                  xml.faculty_id d.faculty_id
                end
              end
            end
          elsif param_type.eql?("people")
            xml.send(:"requested_items") do
              people.each.with_index do |p, i|
                xml.send(:"item", "num" => "#{i + 1}") do
                  xml.personid p.id
                  xml.byear p.year_of_birth
                  xml.last p.last_name
                  xml.first p.first_name
                  xml.external_user_id p.identifiers.where(source_id: Source.find_by_name('xkonto').id).present? ? p.identifiers.where(source_id: Source.find_by_name('xkonto').id).first.value : nil
                end
              end
            end
          elsif param_type.eql?("series")
            xml.send(:"requested_items") do
              series.each.with_index do |s, i|
                xml.send(:"item", "num" => "#{i + 1}") do
                  xml.id s.id
                  xml.title s.title
                  xml.issn s.issn
                end
              end
            end
          end
        end # header

        xml.send(:"upl-records") do
          response["response"]["docs"].each.with_index do |document, index|
            xml.send(:"upl-record", "num" => "#{index + 1}") do
              xml.pubid document["pubid"]
              xml.title document["title"]
              xml.pubyear document["pubyear"]
              xml.send(:"persons") do
                document["person_last_first_extid_mapping"].each do |person|
                  xml.send(:"person_item") do
                    parts = person.split(":")
                    xml.id parts[0]
                    xml.last parts[1]
                    xml.first parts[2]
                  end
                end
              end
              xml.issn document["issn"] unless document["issn"].nil?
              xml.isbn document["isbn"] unless document["isbn"].nil?
            end
          end
          xml.send(:"upl-pages") do
            xml.total_no_of_records response["response"]["numFound"]
          end
        end
     end
    end

    render xml: builder
  end

end