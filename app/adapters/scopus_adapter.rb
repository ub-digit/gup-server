class ScopusAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :eissn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :author, :doi_url, :extid, :xml
  
  include ActiveModel::Serialization
  include ActiveModel::Validations

  DOI_URL_PREFIX = 'http://dx.doi.org/'
  APIKEY = Rails.application.config.datasources[:scopus][:apikey]


  def initialize hash
    @doi = hash[:doi]
    @xml = hash[:xml]
    parse_xml
  end

  def parse_xml
    xml = Nokogiri::XML(@xml).remove_namespaces!


    if xml.search('//feed/entry/error').text.present?
      error_msg = xml.search('//feed/entry/error').text
      puts "Error in ScopusAdapter: #{error_msg}"
      errors.add(:generic, "Error in ScopusAdapter: #{error_msg}")
      return
    end  

    if !xml.search('//feed/entry/title').text.present?
      puts "Error in ScopusAdapter: No content"
      errors.add(:generic, "Error in ScopusAdapter: No content")
      return 
    end  

    @pubyear = ""
    if xml.search('//entry/coverDate').text.present?
      @pubyear = xml.search('//entry/coverDate').text.byteslice(0..3)
    end

    @abstract = xml.search('//entry/description').text

    @keywords = "" 
    if xml.search('//entry/authkeywords').text.present?
      @keywords = xml.search('//entry/authkeywords').text.split(' | ').join(', ')
    end

    # Take care of author ids TBD...

    @author = xml.search('//entry/author/authname').map do |author|
      [author.text]
    end.join("; ")


    @title = xml.search('//entry/title').text
    @issn = xml.search('//entry/issn').text
    @eissn = xml.search('//entry/eIssn').text    
    @sourcetitle = xml.search('//entry/publicationName').text
    @sourcevolume = xml.search('//entry/volume').text
    @sourcepages =xml.search('//entry/pageRange').text

    @extid = xml.search('//entry/identifier').text
    @doi_url = DOI_URL_PREFIX + xml.search('//entry/doi').text
  end

  def self.find id

    headers = {"X-ELS-APIKey" => APIKEY, "X-ELS-ResourceVersion" => "XOCS", "Accept" => "application/atom+xml"}
    response = RestClient.get "http://api.elsevier.com/content/search/index:SCOPUS?count=1&start=0&view=COMPLETE&query=DOI(#{id})", headers

    #puts response
    #puts response.code
    self.new doi:id, xml: response
  end

  def self.find_by_id id
    self.find id
  rescue => error
    puts "Error in ScopusAdapter: #{error}"
    return nil  
  end

end

