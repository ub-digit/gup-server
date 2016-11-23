class EndnoteAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear,
    :language, :issn, :author, :sourcetitle, :sourcevolume, :sourceissue,
    :sourcepages, :publisher, :place, :extent, :isbn, :patent_applicant,
    :patent_date, :patent_number, :extid, :doi, :doi_url, :pmid, :xml,
    :datasource, :sourceid, :publication_identifiers, :publication_links

    # As of EndNote XML v17
    PUBLICATION_TYPES = {
      "Journal Article" => "publication_journal-article",
      "Book" => "publication_book",
      "Thesis" => "publication_doctoral-thesis",
      "Conference Proceedings" => "conference_proceeding",
      "Newspaper Article" => "publication_newspaper-article",
      "Book Section" => "publication_book-chapter",
      "Magazine Article" => "publication_magazine-article",
      "Edited Book" => "publication_edited-book",
      "Report" => "publication_report",
      "Artwork" => "artistic-work_original-creative-work",
      "Patent" => "intellectual-property_patent",
      "Conference Paper" => "conference_paper",
      "Unpublished Work" => "publication_working-paper",
      "Encyclopedia" => "publication_encyclopedia-entry",
    }

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize(endnote_hash)
    @publication_identifiers = []
    adapt_record(endnote_hash)
  end

  # Takes an object that walks and looks lika an EndnoteRecord object.
  def adapt_record(endnote_hash)
    # This will only work with endnote 8
    rec = endnote_hash[:endnote_record]

    #@ref_type = rec.ref_type
    @id = rec.id
    @title = rec.title
    @alt_title = rec.alt_title
    @pubyear = rec.pubyear
    @abstract = rec.abstract
    @language = rec.language
    @keywords = rec.keywords
    # TODO: check this up:
    #@author = xml.search('./contributors/authors/author/style').map do |author|
    #  [author.text]
    #end.join("; ")
    @publisher = rec.publisher
    @place = rec.place
    @patent_applicant = rec.patent_applicant
    @patent_date = rec.patent_date
    @patent_number = rec.patent_number
    @isbn = rec.isbn
    @issn = rec.issn
    @extent =  rec.extent
    @sourcetitle = rec.sourcetitle
    @sourcevolume = rec.sourcevolume
    @sourceissue = rec.sourceissue
    @sourcepages = rec.sourcepages
    @doi = rec.doi
    @doi_url = doi_url
    add_identifier(@doi, 'doi')
    add_identifier(@pubmed, 'pubmed')
    @xml = rec.xml
  end

  def add_identifier(identifier_value, identifier_code)
    unless identifier_value.blank?
      @publication_identifiers << {
        identifier_code: identifier_code,
        identifier_value: identifier_value
      }
    end
  end

  def self.authors(xml)
    #pp xml
    authors = []
    xml.search('//contributors/authors').map do |author|
      style = author.search('style').text
      first_name = style.split(/, /).last
      last_name = style.split(/, /).first
      authors << {
        first_name: first_name,
        last_name: last_name,
        full_author_string: style
      }
    end
    return authors
  end

  # Try to match publication type from xml data into GUP type
  def self.publication_type_suggestion(xml)
    original_pubtype = xml.search('//record/ref-type/@name').text
    pubtype = PUBLICATION_TYPES[original_pubtype]
    return pubtype unless pubtype.nil?
    return "other"
  end

  def json_data(options = {})
    {
      title: @title,
      alt_title: alt_title,
      abstract: abstract,
      pubyear: pubyear,
      keywords: keywords,
      #author: author,
      extent: extent,
      publanguage: Language.language_code_map(language),
      sourcetitle: sourcetitle,
      sourcevolume: sourcevolume,
      sourceissue: sourceissue,
      sourcepages: sourcepages,
      isbn: isbn,
      issn: issn,
      publication_links: publication_links,
      extid: extid,
      xml: xml,
      datasource: datasource,
      sourceid: sourceid,
      publication_identifiers: publication_identifiers
    }
  end

  # In EndnoteAdapter we will only try to check for and update publication_id:s
  def update(source_id, update_hash)
    endnote_record = EndnoteRecord.find_by_id(source_id)
    publication_id = update_hash[:publication_id]
    pp "EndnoteAdapter: setting publication_id to #{publication_id} for EndnoteRecord #{source_id}."
    endnote_record.publication_id = publication_id
  end

  def self.find(endnote_record_id)
    endnote_record = EndnoteRecord.find(endnote_record_id)
    item = self.new(endnote_record: endnote_record)
    item.datasource = 'endnote'
    item.id = endnote_record.id
    item.sourceid = endnote_record.id
    return item
  end

  # implements a find_by_id in order to meet expectations of ImportManager.
  # It returns an "item" produced by the adapter
  # if an error occur reurn nil
  def self.find_by_id(endnote_record_id)
    self.find(endnote_record_id)
  rescue => error
    puts "Error in EndnoteAdapter: #{error}"
    return nil
  end
end
