class EndnoteRecord < ActiveRecord::Base

  #attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :issn, :sourcetitle, :sourcevolume, :sourceissue, :sourcepages, :publisher, :place, :extent, :author, :isbn, :patent_applicant, :patent_date, :patent_number, :links, :extid, :doi_url, :xml

  belongs_to :publications
  has_many :endnote_file_records
  has_many :endnote_files, through: :endnote_file_records

  validates :id, uniqueness: true
  validates :username, presence: true
  validates :checksum, presence: true
  validates :checksum, uniqueness: true

  # def as_json(options = {})
  #   json = super
  #   json.delete('xml')
  #   # json.merge!(
  #   #   {
  #   #     version_id: id,
  #   #     version_created_at: created_at,
  #   #     version_created_by: created_by,
  #   #     version_updated_at: updated_at,
  #   #     version_updated_by: updated_by
  #   #   })
  #   json["endnote_records"] = self.endnote_records
  #   return json
  # end

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
      xml: xml,
      checksum: checksum,
      username: username,
      publication_id: publication_id
    }
  end
end
