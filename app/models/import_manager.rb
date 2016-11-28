class ImportManager
  ADAPTERS = {
    "pubmed" => PubmedAdapter,
    "libris" => LibrisAdapter,
    "scopus" => ScopusAdapter,
    "scigloo" => SciglooAdapter,
    "gupea" => GupeaAdapter,
    "endnote" => EndnoteAdapter
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

  # This is used for writing back values to the adapter after the
  # Publication has been created or updated.
  def self.feedback_to_adapter(datasource:, sourceid:, feedback_hash: {})
    unless feedback_hash.empty?
      adapter = ImportManager.find_adapter(datasource: datasource)
      if defined?(adapter.update) && sourceid.present?
        adapter.update(sourceid, feedback_hash)
      end
    end
  end

end
