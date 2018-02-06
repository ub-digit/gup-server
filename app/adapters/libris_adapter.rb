class LibrisAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :isbn, :author, :extent, :sourcetitle, :extid, :links, :xml, :datasource, :sourceid, :publication_identifiers

  # TODO: Proper types for Libris needed
  PUBLICATION_TYPES = {
    "journalarticle" => "publication_journal-article"
  }

  # Map for translating source ids to configured identifier type
  PUBLICATION_IDENTIFIERS = {
    "SE-LIBR" => "libris-id"
  }

  include ActiveModel::Serialization
  include ActiveModel::Validations

  LIBRIS_ID_PREFIX = 'SE-LIBR: '


  def initialize hash
    @isbn = hash[:isbn]
    @xml = hash[:xml]
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
      extent: extent,
      publanguage: Language.language_code_map(language),
      sourcetitle: sourcetitle,
      isbn: isbn,
      links: links,
      extid: extid,
      xml: xml,
      datasource: datasource,
      sourceid: sourceid,
      publication_identifiers: publication_identifiers
    }
  end
  def self.authors(xml)
    authors = []
    xml.search('//mods/name[@type="personal"]/namePart[not(@type="date")]').map do |author|
      name_part = author.text
      first_name = name_part.split(/, /).last
      last_name = name_part.split(/, /).first
      authors << {
        first_name: first_name,
        last_name: last_name,
        full_author_string: name_part
      }
    end
    authors
  end

  # TODO!
  def self.publication_type_suggestion(xml)
    return "publication_book"
  end

  def parse_xml
    @xml = force_utf8(@xml)
  	xml = Nokogiri::XML(@xml).remove_namespaces!
    if !xml.search('//mods/titleInfo/title').text.present?
      puts "Error in LibrisAdapter: No content"
      errors.add(:generic, "Error in LibrisAdapter: No content")
      return
    end


    @title = xml.search('//mods/titleInfo[not(@type="alternative")]/title').text
    @alt_title = xml.search('//mods/titleInfo[@type="alternative"]/title').text


    @keywords = xml.search('//mods/subject').map do |keyword|
      [keyword.text]
    end.join(", ")

    @pubyear = ""
    if xml.search('//mods/originInfo/dateIssued[@encoding="marc"]').text.length
      @pubyear = xml.search('//mods/originInfo/dateIssued[@encoding="marc"]').text.byteslice(0..3)
    end

    @language = xml.search('//mods/language/languageTerm[@type="code"]')[0].text

    #@author = xml.search('//mods/name[@type="personal"]/namePart[not(@type="date")]').map do |author|
    #  [author.text]
    #end.join("; ")

    @extent = xml.search('//mods/physicalDescription/extent').text

    @extid = ""
    if xml.search('//mods/recordInfo/recordIdentifier[@source="SE-LIBR"]').text
      @extid = LIBRIS_ID_PREFIX + xml.search('//mods/recordInfo/recordIdentifier[@source="SE-LIBR"]').text
    end
    # override isbn
    @isbn = xml.search('//mods/identifier[@type="isbn"]').text

    @publication_identifiers = []
    xml.search('//mods/recordInfo/recordIdentifier').each do |recordIdentifier|
      if PUBLICATION_IDENTIFIERS[recordIdentifier.attr('source')].present?
        @publication_identifiers << {
          identifier_code: PUBLICATION_IDENTIFIERS[recordIdentifier.attr('source')],
          identifier_value: recordIdentifier.text
        }
      end
    end
  end

  def self.find id
  	response = RestClient.get "http://libris.kb.se/xsearch?format_level=full&format=mods&n=1&query=isbn:(#{id})"
  	# response
  	#puts response.code
    item = self.new isbn: id, xml: response
    item.datasource = 'libris'
    item.id = id
    return item
  end

  def self.find_by_id id
    self.find id
  rescue => error
    puts "Error in LibrisAdapter: #{error}"
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
