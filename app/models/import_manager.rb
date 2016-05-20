class ImportManager
  ADAPTERS = {
    "pubmed" => PubmedAdapter,
    "libris" => LibrisAdapter,
    "scopus" => ScopusAdapter,
    "scigloo" => SciglooAdapter,
    "gupea" => GupeaAdapter
  }

  def self.find(datasource:, sourceid:)
    adapter = ImportManager.find_adapter(datasource: datasource)
    return adapter.find_by_id(sourceid)
  end

  def self.find_adapter(datasource: )
    adapter = ADAPTERS[datasource]
    if !adapter
      raise StandardError, "Adapter for datasource #{datasource} not found"
    else
      return adapter
    end
  end

  def self.datasource_valid?(datasource:)
    return ADAPTERS.keys.include?(datasource)
  end
  
end
