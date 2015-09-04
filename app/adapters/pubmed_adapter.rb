class PubmedAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :author, :links, :pmid, :xml, :datasource, :sourceid

  PUBLICATION_TYPES = {
    "journalarticle" => "journal-articles"
  }
  
  include ActiveModel::Serialization
  include ActiveModel::Validations

  DOI_URL_PREFIX = 'http://dx.doi.org/'
  PUBMED_URL_PREFIX = 'http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=PubMed&dopt=Citation&list_uids='


  def initialize hash
    @pmid = hash[:pmid]
    @xml = hash[:xml]
    parse_xml
  end

  def self.authors(xml)
    authors = []
    xml.search('//MedlineCitation/Article/AuthorList/Author').map do |author|
      first_name = author.search('ForeName').text
      last_name = author.search('LastName').text
      affiliation = author.search('Affiliation').text
      authors << {
        first_name: first_name,
        last_name: last_name,
        affiliation: affiliation,
        full_author_string: author.text
      }
    end

    authors
  end

  # Try to match publication type from xml data into GUP type
  def self.publication_type_suggestion(xml)
    original_pubtypes = xml.search('//MedlineCitation/Article/PublicationTypeList/PublicationType').map do |pubtype|
      pubtype.text.downcase.gsub(/[^a-z]/,'')
    end
    return PUBLICATION_TYPES[original_pubtypes.first]
  end

  def parse_xml
    @xml = force_utf8(@xml)

    xml = Nokogiri::XML(@xml)

    if xml.search('//eFetchResult/ERROR').text.present?
      error_msg = xml.search('//eFetchResult/ERROR').text
      puts "Error in PubmedAdapter: #{error_msg}"
      errors.add(:generic, "Error in PubmedAdapter: #{error_msg}")
      return
    end  

    if !xml.search('//PubmedArticleSet/PubmedArticle').text.present?
      puts "Error in PubmedAdapter: No content"
      errors.add(:generic, "Error in PubmedAdapter: No content")
      return 
    end  



    @title = xml.search('//MedlineCitation/Article/ArticleTitle').text
    @alt_title = xml.search('//MedlineCitation/Article/VernacularTitle').text
    @abstract = xml.search('//MedlineCitation/Article/Abstract/AbstractText').text
    @keywords = xml.search('//MedlineCitation/MeshHeadingList/MeshHeading/*[name()="DescriptorName" or name()="QualifierName"]').map do |keyword|
      [keyword.text]
    end.join(", ")
  
    @pubyear = ""
    if xml.search('//MedlineCitation/Article/Journal/JournalIssue/PubDate/Year').text.present?
      @pubyear = xml.search('//MedlineCitation/Article/Journal/JournalIssue/PubDate/Year').text
    else
      xml.search('//MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate').text
    end

    @language = xml.search('//MedlineCitation/Article/Language').text

    @issn = xml.search('//Article/Journal/ISSN').text
    @sourcetitle = xml.search('//Article/Journal/Title').text
    @sourcevolume = xml.search('//Article/Journal/JournalIssue/Volume').text
    @sourceissue = xml.search('//Article/Journal/JournalIssue/Issue').text
    @sourcepages = xml.search('//Article/Pagination/MedlinePgn').text

    #@author = xml.search('//MedlineCitation/Article/AuthorList/Author').map do |author|
    #  [author.search('LastName').text, author.search('ForeName').text].join(", ")
    #end.join("; ")
  
    @pmid = xml.search('//MedlineCitation/PMID').text

    @links = ""
    if !xml.search('//PubmedData/ArticleIdList/ArticleId[@IdType="doi"]').empty?
      @links = DOI_URL_PREFIX + xml.search('//PubmedData/ArticleIdList/ArticleId[@IdType="doi"]').text
    elsif !xml.search('//PubmedData/ArticleIdList/ArticleId[@IdType="pubmed"]').empty?
      @links = PUBMED_URL_PREFIX + xml.search('//PubmedData/ArticleIdList/ArticleId[@IdType="pubmed"]').text
    end
  end


  def self.find id
    response = RestClient.get "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id=#{id}"
    #puts response
    #puts response.code
    self.new pmid:id, xml: response
  end

  def self.find_by_id id
    self.find id
  rescue => error
    puts "Error in PubmedAdapter: #{error}"
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
