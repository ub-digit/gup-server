class PeopleSearchEngine < SearchEngine
  def self.solr
    @@solr ||= RSolr.connect(url: "http://localhost:8983/solr/" + "people/")
  end

  def solr
    PeopleSearchEngine.solr
  end

  def self.query(query)    
    solr.get('select', params: {
      q: query,
      rows: 20,
    }.compact)
  end

  def self.sync_search_engine
    search_engine = PeopleSearchEngine.new
    search_engine.clear(confirm: true)
    Person.where(affiliated: true).where(deleted_at: nil).each do |p|
      puts p.inspect
      document = create_document p
      search_engine.add(data: document)
    end
  ensure
    search_engine.commit
  end

  def self.add_to_search_engine person
    search_engine = PeopleSearchEngine.new
    document = create_document person
    search_engine.add(data: document)
  ensure
    search_engine.commit    
  end

  def self.update_search_engine person
    search_engine = PeopleSearchEngine.new
    search_engine.delete_from_index(id: person.id)    
    document = create_document person
    search_engine.add(data: document)
  ensure
    search_engine.commit  
  end

  def self.delete_from_search_engine person_id
    search_engine = PeopleSearchEngine.new
    search_engine.delete_from_index(id: person_id)    
  ensure
    search_engine.commit
  end

  def self.create_document person
    {
      id: person.id,
      first_name: person.first_name,
      last_name: person.last_name,
      year_of_birth: person.year_of_birth,
      affiliated: person.affiliated,
      created_at: person.created_at,
      updated_at: person.updated_at,
      deleted_at: person.deleted_at,
      created_by: person.created_by,
      updated_by: person.updated_by,
      identifiers: person.identifiers.map{ |i| i.value }
      #has_active_publications: person.has_active_publications?
    }
  end    

end
