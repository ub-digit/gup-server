class PublicationSearchEngine < SearchEngine
  def self.solr
    @@solr ||= RSolr.connect(url: APP_CONFIG['publication_index_url'])
  end

  def solr
    PublicationSearchEngine.solr
  end

  def self.query(query, start, rows)

    query_fields = [
      'id^100',
      'authors_xaccount^100',
      'authors_orcid^100',
      'publication_identifiers^100',
      'authors_full_name^50',
      'title^50',
      'alt_title'
    ]

    solr.paginate(start, rows, "select", params: {
      "defType" => "edismax",
      q: query,
      qf: query_fields.join(" "),
      fl: "score,*"})
  end


  def self.update_search_engine publication
    if Rails.env == "test"
      self.update_search_engine_do publication
    else
      Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          self.update_search_engine_do publication
        end
      }
    end
  end

  def self.delete_from_search_engine publication_id
    if Rails.env == "test"
      self.delete_from_search_engine_do publication_id
    else
      Thread.new {
        ActiveRecord::Base.connection_pool.with_connection do
          self.delete_from_search_engine_do publication_id
        end
      }
    end
  end

  def self.update_search_engine_do publication
    search_engine = PublicationSearchEngine.new
    # Try to delete document from index 
    search_engine.delete_from_index(ids: publication.id)
    document = create_document publication
    search_engine.add(data: document)
  ensure
    search_engine.commit
  end

  def self.delete_from_search_engine_do publication_id
    search_engine = PublicationSearchEngine.new
    search_engine.delete_from_index(ids: publication_id)
  ensure
    search_engine.commit
  end

  def self.create_document publication
    {
      id: publication.id,
      current_version_id: publication.current_version.id,
      title: publication.current_version.title,
      alt_title: publication.current_version.alt_title,
      authors_full_name: publication.current_version.get_authors_full_name,
      authors_xaccount: publication.current_version.get_authors_identifier(source: 'xkonto'),
      authors_orcid: publication.current_version.get_authors_identifier(source: 'orcid'),
      publication_identifiers: publication.current_version.get_identifiers
    }
  end

end
