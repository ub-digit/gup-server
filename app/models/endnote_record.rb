class EndnoteRecord < ActiveRecord::Base

  # attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear,
  #   :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages,
  #   :publisher, :place, :extent, :author, :isbn, :patent_applicant,
  #   :patent_date, :patent_number, :links, :extid, :doi_url, :xml

  belongs_to :publications
  has_many :endnote_file_records
  has_many :endnote_files, through: :endnote_file_records

  validates :id, uniqueness: true
  validates :username, presence: true
  validates :checksum, presence: true
  validates :checksum, uniqueness: true

  DOI_URL_PREFIX = 'http://dx.doi.org/'
  PERIODICAL_TYPES = [5, 17, 19, 23, 47]
  MONOGRAPH_TYPES = [6, 25, 27, 28, 32]
  PATENT_TYPES = [25]

  # Returns true if it is OK to delete the EndnoteRecord
  # It would be OK if the record is not part of any EndnoteFile
  # and if it is not associated with any Publication object.
  def is_destroyable
    return false if self.publication_id
    return false if self.endnote_files.count > 0
    return true
  end

  def as_json options = {}
    {
      id: id,
      title: title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
###      #author: author,
      language: language,
      sourcetitle: sourcetitle,
      sourceissue: sourceissue,
      sourcevolume: sourcevolume,
      sourcepages: sourcepages,
      issn: issn,
      publisher: publisher,
      place: place,
      extent: extent,
      isbn: isbn,
      patent_applicant: patent_applicant,
      patent_date: patent_date,
      patent_number: patent_number,
      doi: doi,
      doi_url: doi_url,
      extid: extid,
      xml: xml,
      checksum: checksum,
      username: username,
      rec_number: rec_number,
      db_id: db_id,
      publication_id: publication_id,
      process_state: get_process_state(publication_id),
      duplicates_suggestions: Publication.duplicates(publication_identifiers())
    }
  end

  def publication_identifiers()
    identifiers = []
    if self.doi
      doi = {identifier_code: 'doi', identifier_value: self.doi}
      identifiers << doi
    end
    #pmid = {identifier_code: 'pmid', identifier_value: 'sdfasdf'}
    return identifiers
  end

  def get_process_state(publication_id)
    return nil if publication_id.blank?
    Publication.find(publication_id).current_process_state
  end

  def self.parse xml
    #pp '-*- EndnoteAdapter.parse_xml -*-'
    endnote_record = EndnoteRecord.new
    # This will only work with endnote 8
    #@xml = force_utf8(@xml)

    #endnote_record.ref_type = xml.search('./ref-type').text.to_i
    ref_type = xml.search('./ref-type').text.to_i

    endnote_record.title = xml.search('./titles/title/style').text
    endnote_record.alt_title = xml.search('./titles/secondary_title/style').text
    endnote_record.pubyear = xml.search('./dates/year/style').text
    endnote_record.abstract = xml.search('./abstract/style').text
    endnote_record.language = xml.search('./language/style').text.split("\r").first

    endnote_record.keywords = xml.search('./keywords/keyword/style').map do |keyword|
      [keyword.text]
    end.join(", ")

    #@author = xml.search('./contributors/authors/author/style').map do |author|
    #  [author.text]
    #end.join("; ")

    endnote_record.publisher = xml.search('./publisher/style').text
    endnote_record.place = xml.search('./pub-location/style').text

    if PATENT_TYPES.include?(ref_type)
      endnote_record.patent_applicant = xml.search('./publisher/style').text
      endnote_record.patent_date = xml.search('./date/style').text
      endnote_record.patent_number = xml.search('./isbn/style').text
    end

    if MONOGRAPH_TYPES.include?(ref_type)
      endnote_record.isbn = xml.search('./isbn/style').text
    else
      endnote_record.issn = xml.search('./isbn/style').text
    end

    if MONOGRAPH_TYPES.include?(ref_type)
      endnote_record.extent =  xml.search('./pages/style').text
    end

    if PERIODICAL_TYPES.include?(ref_type)
      endnote_record.sourcetitle = xml.search('./periodical/full-title/style').text
      endnote_record.sourcevolume = xml.search('./volume/style').text
      endnote_record.sourceissue = xml.search('./number/style').text
      endnote_record.sourcepages = xml.search('./pages/style').text
    end

    if xml.search('./electronic-resource-num/style').text.present?
      #endnote_record.doi_url = DOI_URL_PREFIX + xml.search('./electronic-resource-num/style').text
      endnote_record.doi = xml.search('./electronic-resource-num/style').text
      endnote_record.doi_url = DOI_URL_PREFIX + xml.search('./electronic-resource-num/style').text
    end

    endnote_record.extid = xml.search('./accession-num/style').text
    return endnote_record

  end
end
