class EndnoteRecord < ActiveRecord::Base

  #attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :publisher, :place, :extent, :author, :isbn, :patent_applicant, :patent_date, :patent_number, :links, :extid, :doi_url, :xml

  belongs_to :publications
  has_many :endnote_file_records
  has_many :endnote_files, through: :endnote_file_records

  validates :id, uniqueness: true
  validates :username, presence: true
  validates :checksum, presence: true
  validates :checksum, uniqueness: true


  def as_json options = {}
    {
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
      links: doi_url,
      extid: extid,
      xml: xml
    }
  end
end
