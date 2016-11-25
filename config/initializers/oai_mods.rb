module OAI::Provider::Metadata

  # Simple implementation of the MODS metadata format.
  class OAI_MODS < Format

    def initialize
      @prefix = 'mods'
      @element_namespace = 'mods'
      @schema = 'http://www.loc.gov/standards/mods/v3/mods-3-5.xsd'
      @namespace = 'http://www.loc.gov/mods/v3/'
    end

  end
end
