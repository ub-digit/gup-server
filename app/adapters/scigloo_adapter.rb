class SciglooAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :author, :links, :xml, :datasource, :sourceid, :category_hsv_local,:publication_identifiers, :sgid

  include ActiveModel::Serialization
  include ActiveModel::Validations

  ID_MAP = {
    "PubMedID" => "pubmed",
    "DOI" => "doi",
    "ISI-ID" => "isi-id",
    "SCOPUS-ID" => "scopus-id",
    "Handle" => "handle",
    "Libris OMR" => "libris-id"
  }
  
  def initialize hash
    @sgid = hash[:sgid]
    @xml = hash[:xml]
    parse_xml
  end

  
  def json_data options = {}
    {
      title: title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
      #author: author,
      publanguage: Language.language_code_map(language),
      sourcetitle: sourcetitle,
      sourceissue: sourceissue,
      sourcevolume: sourcevolume, 
      sourcepages: sourcepages,
      issn: issn,
      links: links,
      extid: sgid,
      xml: xml,
      category_hsv_local: category_hsv_local,
      datasource: datasource,
      sourceid: sourceid,
      publication_identifiers: publication_identifiers
    }
  end

  def self.authors(xml)
    dep_for_pid = {}
    xkonto_for_pid = {}
    name_for_pid = {}
    pids = []

    xml.search('//arr[@name="person_id"]/int').each do |pid| 
      pids << pid.text.to_i
    end
    xml.search('//arr[@name="person_mapping"]/str').each do |mapping| 
      pid,name = mapping.text.split(/:/,2)
      lname,fname = name.split(/, /)
      name_for_pid[pid.to_i] = {
        name: name,
        fname: fname,
        lname: lname
      }
    end
    xml.search('//arr[@name="personid_extid_mapping"]/str').each do |mapping| 
      pid,extid = mapping.text.split(/:/,2)
      xkonto_for_pid[pid.to_i] = extid
    end
    xml.search('//arr[@name="department_person_mapping"]/str').each do |mapping| 
      dep,pid = mapping.text.split(/:/,2)
      dep_for_pid[pid.to_i] ||= []
      dep_for_pid[pid.to_i] << dep.to_i
      dep_for_pid[pid.to_i] = dep_for_pid[pid.to_i].uniq
    end

    authors = []
    pids.each do |pid| 
      affiliation = dep_for_pid[pid]
      authors << {
        first_name: name_for_pid[pid][:fname],
        last_name: name_for_pid[pid][:lname],
        affiliation: affiliation,
        full_author_string: name_for_pid[pid][:name],
        xaccount: xkonto_for_pid[pid]
      }
    end
    
    authors
  end

  def self.publication_type_suggestion(xml)
    return nil
  end
  
  def parse_xml
    @xml = force_utf8(@xml)
    xml = Nokogiri::XML(@xml)

    if xml.search('//response/lst[@name="error"]').text.present?
      error_msg = xml.search('//response/lst[@name="error"]/str[@name="msg"]').text
      puts "Error in SciglooAdapter: #{error_msg}"
      errors.add(:generic, "Error in SciglooAdapter: #{error_msg}")
      return
    end  

    doc = xml.search('//response/result[@name="response"]/doc')
    
    @title = doc.search('//str[@name="title"]').text
    @pubyear = doc.search('//int[@name="pubyear"]').text
    @abstract = doc.search('//str[@name="abstract"]').text
    @language = doc.search('//str[@name="language_iso"]').text
    @issn = doc.search('//str[@name="issn"]').text
    @sourcetitle = doc.search('//str[@name="sourcetitle"]').text
    @sourcevolume = doc.search('//str[@name="sourcevolume"]').text
    @sourceissue = doc.search('//str[@name="sourceissue"]').text
    @sourcepages = doc.search('//str[@name="sourcepages"]').text
    @publication_identifiers = []
    doc.search('//arr[@name="extid_mapping"]/str').each do |mapping| 
      extsrc,extid = mapping.text.split(/:/, 2)
      @publication_identifiers << {
        identifier_code: ID_MAP[extsrc],
        identifier_value: extid
      }
    end
    @category_hsv_local = []
    doc.search('//arr[@name="svepid"]/int').each do |mapping| 
      @category_hsv_local << mapping.text.to_i
    end
  end
  
  def self.find id
    response = RestClient.get "http://solr.lib.chalmers.se:8080/solr/scigloo/select?q=*%3A*&fq=pubid%3A#{id}&wt=xml&indent=true"
    #puts response
    #puts response.code
    item = self.new pmid:id, xml: response
    item.datasource = 'scigloo'
    item.sourceid = id
    return item
  end

  def self.find_by_id id
    self.find id
  rescue => error
    puts "Error in SciglooAdapter: #{error}"
    return nil  
  end

  private
  def force_utf8(str)
    if !str.force_encoding("UTF-8").valid_encoding?
      str = str.force_encoding("ISO-8859-1").encode("UTF-8")
    end
    return str
  end

end
