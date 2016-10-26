class  OaiDocuments
  class DC
    def self.create_record publication
      xml = ::Builder::XmlMarkup.new
      xml.tag!("oai_dc:dc", 
       'xmlns:oai_dc' => "http://www.openarchives.org/OAI/2.0/oai_dc/", 
       'xmlns:dc' => "http://purl.org/dc/elements/1.1/",
       'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
       'xsi:schemaLocation' => %{http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd}) do
        publication.current_version.get_authors_full_name.each { |author| xml.tag!('oai_dc:creator', author)} unless publication.current_version.get_authors_full_name.nil?
        xml.tag!('oai_dc:date', publication.current_version.pubyear) unless publication.current_version.pubyear.nil?
        xml.tag!('oai_dc:description', publication.current_version.abstract) unless publication.current_version.abstract.nil?
        xml.tag!('oai_dc:identifier', get_identifier(publication))
        xml.tag!('oai_dc:language', publication.current_version.publanguage) unless publication.current_version.publanguage.nil?
        xml.tag!('oai_dc:publisher', publication.current_version.publisher) unless (publication.current_version.publisher.nil?)
        xml.tag!('oai_dc:relation', publication.current_version.series.first.title) unless (publication.current_version.series.nil? || publication.current_version.series.first.nil? || publication.current_version.series.first.title.nil?)
        publication.current_version.keywords.split(",").each { |keyword| xml.tag!('oai_dc:subject', keyword)} unless publication.current_version.keywords.nil?
        xml.tag!('oai_dc:title', publication.current_version.title) unless publication.current_version.title.nil?
        xml.tag!('oai_dc:type', publication.current_version.publication_type.code) unless (publication.current_version.publication_type.nil? || publication.current_version.publication_type.code.nil?)
      end
      xml.target!
    end

    def self.get_identifier publication
      #TODO : hostname + path + publication.id
      publication.id
    end


  end
end
