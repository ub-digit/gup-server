class GupeaAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :isbn, :author, :disslocation, :dissdate, :sourcetitle, :artwork_type, :links, :handle_suffix, :xml, :datasource, :sourceid, :publication_identifiers

  PUBLICATION_TYPES = {
    "report" => "publication_report",
    "article - peer reviewed scientific" => "publication_journal-article",
    "article - other scientific" => "publication_magazine-article",
    "article - other" => "publication_magazine-article",
    "article - review" => "publication_book-review",
    "book" => "publication_book",
    "book chapter" => "publication_book-chapter",
    "licentiate thesis" => "publication_licentiate-thesis",
    "doctoral thesis" => "publication_doctoral-thesis",
    "conference paper - peer reviewed" => "conference_paper",
    "conference paper - other" => "conference_other",
    "conference-conference_poster" => "conference_poster",
    "patent" => "intellectual-property_patent",
    "artistic work" => "artistic-work_original-creative-work",
    "other" => "other"
  }

  include ActiveModel::Serialization
  include ActiveModel::Validations

  def initialize hash
    @handle_suffix = hash[:handle_suffix]
    @xml = hash[:xml]
    @publication_identifiers = [{identifier_code: 'handle', identifier_value: "2077/#{@handle_suffix}"}]
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
      isbn: isbn,
      links: links,
      sourcetitle: sourcetitle,
      artwork_type: artwork_type,
      disslocation: disslocation,
      dissdate: dissdate,
      xml: xml,
      datasource: datasource,
      sourceid: sourceid,
      publication_identifiers: publication_identifiers
    }
  end
  def self.authors(xml)
    authors = []
    xml.search('//metadata/mods/name').map do |author|
      if author.search('role/roleTerm').text.eql?("author")
        name_part = author.search("namePart").text
        first_name = name_part.split(/, /).last
        last_name = name_part.split(/, /).first
        authors << {
          first_name: first_name,
          last_name: last_name,
          full_author_string: name_part
        }
      end
    end
    authors
  end

  def self.publication_type_suggestion(xml)
    original_pubtype = xml.search('//metadata/mods/genre[@type="svep"]').text.downcase
    return PUBLICATION_TYPES[original_pubtype]
  end

  def parse_xml
    @xml = force_utf8(@xml)
  	xml = Nokogiri::XML(@xml).remove_namespaces!

    if xml.search('//OAI-PMH/error').text.present?
      error_msg = xml.search('//OAI-PMH/error').text
      puts "Error in GupeaAdapter: #{error_msg}"
      errors.add(:generic, "Error in GupeaAdapter: #{error_msg}")
      return
    end

    @title = xml.search('//metadata/mods/titleInfo[not(@type="alternative")]/title').text
    @alt_title = xml.search('//metadata/mods/titleInfo[@type="alternative"]/title').text

    @abstract = ""
    if xml.search('//metadata/mods/abstract').text.present?
      @abstract = xml.search('//metadata/mods/abstract').text
    else
      # For artistic works
      @abstract = xml.search('//metadata/mods/note[@type="summary"]').text
    end


    @keywords = xml.search('//metadata/mods/subject').map do |keyword|
      [keyword.text]
    end.join(", ")

    @pubyear = ""
    if xml.search('//metadata/mods/originInfo/dateIssued').text.length
      @pubyear = xml.search('//metadata/mods/originInfo/dateIssued').text.byteslice(0..3)
    end

    @language = xml.search('//metadata/mods/language/languageTerm').text

  	@isbn = xml.search('//metadata/mods/identifier[@type="isbn"]').map do |isbn|
      [isbn.text]
    end.join("; ")

	  # Match just //metadata/mods/name/role/roleTerm = author, TODO
    #@author = xml.search('//metadata/mods/name/namePart').map do |author|
    #  [author.text]
    #end.join("; ")

    @links = xml.search('//metadata/mods/identifier[@type="uri"]').text


    @dissdate = xml.search('//metadata/mods/originInfo/dateOther[@type="defence"]').text
    @disslocation = xml.search('//metadata/mods/note[@type="Venue"]').text

    # For artistic works
    @artwork_type = xml.search('//metadata/mods/note[@type="type of work"]').text
    @sourcetitle = xml.search('//metadata/mods/note[@type="published in"]').text
  end


  def self.find id
  	response = RestClient.get "http://gupea.ub.gu.se/dspace-oai/request?verb=GetRecord&metadataPrefix=scigloo&identifier=oai:gupea.ub.gu.se:2077/#{id}"
  	# response
  	#puts response.code
    item = self.new handle_suffix:id, xml: response
    item.datasource = 'gupea'
    item.sourceid = id
    return item
  end

  def self.find_by_id id
    self.find id
  rescue => error
    puts "Error in GupeaAdapter: #{error}"
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
