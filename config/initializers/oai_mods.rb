module OAI::Provider::Metadata

  # Simple implementation of the MODS metadata format.
  class OAI_MODS < Format

    def initialize
      @prefix = 'mods'
      @element_namespace = 'mods'
    end

  end
end
