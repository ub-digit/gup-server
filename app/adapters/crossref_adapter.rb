class CrossrefAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :author, :links, :doi_url, :xml
  
  include ActiveModel::Serialization
  include ActiveModel::Validations

  DOI_URL_PREFIX = 'http://dx.doi.org/'
  APIKEY = '' # Rails.application.config.datasources[:crossref][:apikey]

  def initialize hash
  	@doi = hash[:doi]
    @xml = hash[:xml]
    parse_xml
  end

  def parse_xml
    @xml = force_utf8(@xml)
    xml = Nokogiri::XML(@xml).remove_namespaces!

    @title = xml.search('//doi_record/crossref/journal/journal_article/titles/title').text
 
    @pubyear = xml.search('//doi_record/crossref/journal/journal_article/publication_date/year').text

    @links = DOI_URL_PREFIX + xml.search('//PubmedData/ArticleIdList/ArticleId[@IdType="doi"]').text  
    @doi_url = DOI_URL_PREFIX + xml.search('// doi_data/doi').text
  end
  
  def self.find id
    response = RestClient.get "http://doi.crossref.org/servlet/query?pid=#{APIKEY}&format=xml&id=#{id}"
    #puts response
    #puts response.code
    self.new doi:id, xml: response
  end

  def self.find_by_id id
    self.find id
  rescue => error
    puts "Error in CrossrefAdapter: #{error}"
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
