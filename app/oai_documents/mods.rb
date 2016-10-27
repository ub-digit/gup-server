class OaiDocuments
  class MODS
    def self.create_record publication
      xml = ::Builder::XmlMarkup.new
      xml.tag!("mods",
               'version' => '3.5',
               'xsi:schemaLocation' => %{http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd}) do
        # Add fields...
      end
      xml.target!
    end

  end
end