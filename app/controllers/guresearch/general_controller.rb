class Guresearch::GeneralController < ApplicationController

  def solr
    @@rsolr ||= RSolr.connect(url: APP_CONFIG['gu_research_index_url'])
  end

  def list_publications
    pubid =         params[:pubid] || ''
    svepid =        params[:svepid] || ''
    catid =         params[:catid] || ''
    userid =        params[:userid] || ''
    departmentid =  params[:departmentid] || ''
    palassoid =     params[:palassoid] || ''

    lyear =         params[:lyear] || '1900'
    hyear =         params[:hyear] || '9999'
    spost =         params[:spost] || '0'
    npost =         params[:npost] || '0'

    mode = ''
    fq = []
    if pubid.present?
      fq.push('pubid:' + pubid)
      mode = 'pubid'
      npost = '1'
    elsif svepid.present?
      fq.push('svepid:' + svepid + '*')
      # Do not include external departments when filtering by subject category
      fq.push('department_id:[0 TO 665] OR department_id:[667 TO *]')
      mode = 'svepid'
      sql_str = "SELECT p.id, p.last_name, p.first_name, p.year_of_birth, i.value, count(p.id) co
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
              AND CAST(c.svepid AS text) LIKE ?
              GROUP BY p.id, p.last_name, p.first_name, p.year_of_birth, i.value
              ORDER BY co DESC"
      person_list = Person.find_by_sql([sql_str, svepid])
    elsif catid.present?
      fq.push("category_id:" + catid)
      # Do not include external departments when filtering by subject category
      fq.push('department_id:[0 TO 665] OR department_id:[667 TO *]')
      mode = 'catid'
      sql_str = "SELECT p.id, p.last_name, p.first_name, p.year_of_birth, i.value, count(p.id) co
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
              AND c.id = ?
              GROUP BY p.id, p.last_name, p.first_name, p.year_of_birth, i.value
              ORDER BY co DESC"
      person_list = Person.find_by_sql([sql_str, catid])
    elsif userid.present?
      fq.push("person_extid:" + userid)
      mode = 'userid'
      sql_str = "SELECT c.id, c.name_sv, c.name_en, count(c.id) co
                  FROM categories c
                  JOIN categories2publications c2p ON c2p.category_id = c.id
                  JOIN publication_versions pv ON pv.id = c2p.publication_version_id
                  JOIN publications publ ON publ.current_version_id = pv.id
                  JOIN people2publications p2p ON p2p.publication_version_id = pv.id
                  JOIN identifiers i ON i.person_id = p2p.person_id
                  JOIN sources s ON s.id = i.source_id
                  WHERE s.name = 'xkonto'
                  AND publ.deleted_at IS NULL
                  AND publ.published_at IS NOT NULL
                  AND i.value like ?
                  AND pv.pubyear >= ?
                  AND pv.pubyear <= ?
                  GROUP BY c.id, c.name_sv, c.name_en
                  HAVING count(c.id) > 1
                  ORDER BY co DESC
                  LIMIT 20"
      category_list = Category.find_by_sql([sql_str, userid, lyear, hyear])
    elsif departmentid.present?
      fq.push('department_id:' + departmentid)
      mode = 'departmentid'
      sql_str = "SELECT c.id, c.name_sv, c.name_en, count(c.id) co
                  FROM categories c
                  JOIN categories2publications c2p ON c2p.category_id = c.id
                  JOIN publication_versions pv ON pv.id = c2p.publication_version_id
                  JOIN publications publ ON publ.current_version_id = pv.id
                  JOIN people2publications p2p ON p2p.publication_version_id = pv.id
                  JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id = p2p.id
                  JOIN departments d ON d2p2p.department_id = d.id
                  WHERE publ.deleted_at IS NULL
                  AND publ.published_at IS NOT NULL
                  AND d.id = ?
                  AND pv.pubyear >= ?
                  AND pv.pubyear <= ?
                  GROUP BY c.id, c.name_sv, c.name_en
                  HAVING count(c.id) > 1
                  ORDER BY co DESC
                  LIMIT 20"
      category_list = Category.find_by_sql([sql_str, departmentid, lyear, hyear])
    elsif palassoid.present?
      fq.push("palassoid:" + palassoid)
      mode = 'palassoid'
      sql_str = "SELECT c.id, c.name_sv, c.name_en, count(c.id) co
                  FROM categories c
                  JOIN categories2publications c2p ON c2p.category_id = c.id
                  JOIN publication_versions pv ON pv.id = c2p.publication_version_id
                  JOIN publications publ ON publ.current_version_id = pv.id
                  JOIN people2publications p2p ON p2p.publication_version_id = pv.id
                  JOIN departments2people2publications d2p2p ON d2p2p.people2publication_id = p2p.id
                  JOIN departments d ON d2p2p.department_id = d.id
                  WHERE publ.deleted_at IS NULL
                  AND publ.published_at IS NOT NULL
                  AND d.palassoid = ?
                  AND pv.pubyear >= ?
                  AND pv.pubyear <= ?
                  GROUP BY c.id, c.name_sv, c.name_en
                  HAVING count(c.id) > 1
                  ORDER BY co DESC
                  LIMIT 20"
      category_list = Category.find_by_sql([sql_str, palassoid, lyear, hyear])
    else
      render nothing: true
      return
    end

    fq.push("pubyear:[" + lyear + " TO " + hyear + "]")
    sort = "pubyear desc,modified desc"

    response = solr.get 'select', :params => {:q => "*:*", :fq => fq, :wt=> 'xml', :sort => sort, :start => spost.to_i, :rows => npost.to_i}
    publications = Nokogiri::XML(response)

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.xmlpage do
        if mode.eql?("pubid")
          # DO NOTHING
        elsif mode.eql?("catid") || mode.eql?("svepid")
          xml.send(:"researchers") do
            person_list.each.with_index do |p, i|
              xml.send(:"researcher", "num" => "#{i + 1}") do
                xml.personid p.id
                xml.last p.last_name
                xml.first p.first_name
                xml.external_user_id p.value
                xml.publications p.co
              end
            end
          end
        elsif mode.eql?("userid") || mode.eql?("departmentid") || mode.eql?("palassoid")
          xml.send(:"relatedcategories") do
            category_list.each.with_index do |c, i|
              xml.send(:"categories", "num" => "#{i + 1}") do
                xml.catid c.id
                xml.sv_name c.name_sv
                xml.en_name c.name_en
                xml.antal c.co
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
              AND CAST(c.svepid AS text) LIKE ?
              AND pv.pubyear >= ?
              AND pv.pubyear <= ?
              GROUP BY p.id, p.last_name, p.first_name, p.year_of_birth, i.value
              HAVING count(p.id) > 1
              ORDER BY p.last_name, p.first_name"

  person_list = Person.find_by_sql([sql_str, svepid, lyear, hyear])
  if person_list.blank?
    render nothing: true
    return
  end
  person_list_sliced = (npost.to_i == -1) ? person_list[spost.to_i..-1] : person_list[spost.to_i, npost.to_i]
  if person_list_sliced.blank?
    render nothing: true
    return
  end

  total = person_list.length
  items = person_list_sliced.length

  builder = Nokogiri::XML::Builder.new do |xml|
    xml.send(:"upl-records-researchers") do
      xml.send(:"header") do
        xml.items items
        xml.total total
      end
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
        fq.push(URI.decode_www_form_component(p[3..-1]))
      end
    end

    q  =    params[:q] || "*:*"
    wt =    params[:wt] || "json"
    start = params[:start] || 0
    rows =  params[:rows] || 10
    sort =  params[:sort] || 'pubyear desc,modified desc'


    response = solr.get 'select', :params => {:q => q, :fq => fq, :wt=> wt, :sort => sort, :start => start.to_i, :rows => rows.to_i}

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
      elsif param_type.eql?("people")
        fq_id = 'person_id:'
        people = Person.where(id: ids.split(",").map{ |id| id.to_i })
      elsif param_type.eql?("series")
        fq_id = 'serie_id:'
        series = Serie.where(id: ids.split(",").map{ |id| id.to_i })
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
    response = solr.get 'select', :params => {:q => "*:*", :fq => fq, :wt=> 'json', :start => 0, :rows => 0,}

    start = 0
    #rows = response["response"]["numFound"].to_i > 500 ? 500 : response["response"]["numFound"].to_i

    rows = response["response"]["numFound"].to_i
    sort = "pubyear desc,modified desc"


    response = solr.get 'select', :params => {:q => "*:*", :fq => fq, :wt=> 'json', :sort => sort, :start => start, :rows => rows}

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.send(:"upl-records-publications") do
        xml.send(:"header") do
          xml.url_prefix_detailed_record APP_CONFIG['public_base_url'] + APP_CONFIG['publication_path']

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
          response["response"]["docs"].each.with_index do |document, i|
            xml.send(:"upl-record", "num" => "#{i + 1}") do
              xml.pubid document["pubid"]
              xml.title document["title"]
              xml.pubyear document["pubyear"]
              xml.send(:"persons") do
                document["person_last_first_extid_listplace_mapping"].each do |person|
                  xml.send(:"persons_item") do
                    parts = person.split(":")
                    xml.id parts[0]
                    xml.last parts[1]
                    xml.first parts[2]
                    xml.listplace parts[4]

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