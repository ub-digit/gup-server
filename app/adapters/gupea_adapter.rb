class GupeaAdapter
  attr_accessor :id, :title, :alt_title, :abstract, :keywords, :pubyear, :language, :isbn, :author, :disslocation, :dissdate, :sourcetitle, :artwork_type, :links, :handle_suffix, :xml
  
  include ActiveModel::Serialization
  include ActiveModel::Validations



  def initialize hash
    @handle_suffix = hash[:handle_suffix]
    @xml = hash[:xml]
    parse_xml
  end

  def parse_xml
  	xml = Nokogiri::XML(@xml).remove_namespaces!

    if xml.search('//OAI-PMH/error').text.present?
      error_msg = xml.search('//OAI-PMH/error').text
      puts "Error in GupeaAdapter: #{error_msg}"
      errors.add(:generic, "Error in GupeaAdapter: #{error_msg}")
      return
    end  

    if !xml.search('//OAI-PMH/GetRecord/record/metadata/mods').text.present?
      puts "Error in GupeaAdapter: No content"
      errors.add(:generic, "Error in GupeaAdapter: No content")
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
    @author = xml.search('//metadata/mods/name/namePart').map do |author|
      [author.text]
    end.join("; ")

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
    self.new handle_suffix:id, xml: response
  end

  def self.find_by_id id
    self.find id
  rescue => error
    puts "Error in GupeaAdapter: #{error}"
    return nil  
  end

end