class LibrisAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :isbn, :author, :extent, :sourcetitle, :extid, :links, :xml
  
  include ActiveModel::Serialization
  include ActiveModel::Validations

  LIBRIS_ID_PREFIX = 'SE-LIBR: '


  def initialize hash
    @isbn = hash[:isbn]
    @xml = hash[:xml]
    parse_xml
  end

  def parse_xml
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

    @language = xml.search('//mods/language/languageTerm[@type="code"]').text

    @author = xml.search('//mods/name[@type="personal"]/namePart[not(@type="date")]').map do |author|
      [author.text]
    end.join("; ")

    @extent = xml.search('//mods/physicalDescription/extent').text
    
    @extid = ""
    if xml.search('//mods/recordInfo/recordIdentifier[@source="SE-LIBR"]').text
      @extid = LIBRIS_ID_PREFIX + xml.search('//mods/recordInfo/recordIdentifier[@source="SE-LIBR"]').text
    end
    # override isbn
    @isbn = xml.search('//mods/identifier[@type="isbn"]').text

  end

  def self.find id
  	response = RestClient.get "http://libris.kb.se/xsearch?format_level=full&format=mods&n=1&query=isbn:(#{id})"
  	# response
  	#puts response.code
    self.new isbn: id, xml: response
  end

  def self.find_by_id id
    self.find id
  rescue => error
    puts "Error in LibrisAdapter: #{error}"
    return nil  
  end

end