class EndnoteAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :publisher, :place, :extent, :author, :isbn, :patent_applicant, :patent_date, :patent_number, :links, :extid, :doi_url, :xml
  
  include ActiveModel::Serialization

  DOI_URL_PREFIX = 'http://dx.doi.org/'
  
  PERIODICAL_TYPES = [5, 17, 19, 23, 47]
  MONOGRAPH_TYPES = [6, 25, 27, 28, 32]
  PATENT_TYPES = [25]
  #EDITED_BOOK_TYPES = [28]

  def initialize hash
    @xml = hash[:xml]
    parse_xml
  end

  def parse_xml
    # This will only work with endnote 8

    ref_type = @xml.search('./ref-type').text.to_i

    @title = @xml.search('./titles/title/style').text
    @alt_title = @xml.search('./titles/secondary_title/style').text
    @pubyear = @xml.search('./dates/year/style').text
    @abstract = xml.search('./abstract/style').text
    @language = @xml.search('./language/style').text

    @keywords = xml.search('./keywords/keyword/style').map do |keyword|
      [keyword.text]
    end.join(", ")

    @author = xml.search('./contributors/authors/author/style').map do |author|
      [author.text]
    end.join("; ")

    @publisher = @xml.search('./publisher/style').text
    @place = @xml.search('./pub-location/style').text

    if PATENT_TYPES.include?(ref_type)
      patent_applicant = @xml.search('./publisher/style').text
      patent_date = @xml.search('./date/style').text
      patent_number = @xml.search('./isbn/style').text
    end
    
    if MONOGRAPH_TYPES.include?(ref_type)
      @isbn = @xml.search('./isbn/style').text
    else 
      @issn = @xml.search('./isbn/style').text
    end

    if MONOGRAPH_TYPES.include?(ref_type)
      @extent =  @xml.search('./pages/style').text
    end

    if PERIODICAL_TYPES.include?(ref_type)
      @sourcetitle = @xml.search('./periodical/full-title/style').text
      @sourcevolume = @xml.search('./volume/style').text
      @sourceissue = @xml.search('./number/style').text
      @sourcepages = @xml.search('./pages/style').text
    end

    if @xml.search('./electronic-resource-num/style').text.present?
      @doi_url = DOI_URL_PREFIX + @xml.search('./electronic-resource-num/style').text
    end 

    @extid = @xml.search('./accession-num/style').text
    
  end
  
  def self.parse xml
    self.new xml: xml
  end


end
