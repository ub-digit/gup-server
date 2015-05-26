class PubmedAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :author, :links, :pmid, :xml
  
  include ActiveModel::Serialization
  include ActiveModel::Validations

  DOI_URL_PREFIX = 'http://dx.doi.org/'
  PUBMED_URL_PREFIX = 'http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=PubMed&dopt=Citation&list_uids='


  def initialize hash
    @pmid = hash[:pmid]
    @xml = hash[:xml]
    parse_xml
  end


  def parse_xml
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


    # For future use
    original_pubtypes = xml.search('//MedlineCitation/Article/PublicationTypeList/PublicationType').map do |pubtype|
      [pubtype.text]
    end.join("; ")

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

    @author = xml.search('//MedlineCitation/Article/AuthorList/Author').map do |author|
      [author.search('LastName').text, author.search('ForeName').text].join(", ")
    end.join("; ")
  
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

end
