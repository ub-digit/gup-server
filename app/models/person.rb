class Person < ActiveRecord::Base
  has_many :alternative_names
  has_many :identifiers
  has_many :sources, :through => :identifiers
  default_scope { where(deleted_at: nil) }
  validates_presence_of :last_name

  def as_json(opts={})
    data = {
      id: id,
      year_of_birth: year_of_birth,
      first_name: first_name,
      last_name: last_name,
      affiliated: affiliated,
      created_at: created_at,
      updated_at: updated_at,
      identifiers: identifiers.as_json,
      alternative_names: alternative_names.as_json,
    }
    if opts[:include_publication_status]
      data[:has_active_publications] = has_active_publications?
    end
    return data
  end

  # Returns all people based on identifier for source
  def self.find_all_from_identifier(source:, identifier:)
    person_ids = Identifier.joins(:source).where(sources: {name: source}).where(value: identifier).select(:person_id)
    return Person.where(id: person_ids)
  end

  def presentation_string(affiliations = [])
    str = ""
    str << first_name if respond_to?(:first_name) && first_name.present?
    str << " "
    str << last_name if respond_to?(:last_name) && last_name.present?
    str << ", #{year_of_birth}" if respond_to?(:year_of_birth) && year_of_birth.present?
    str << " (#{identifier_string})" if identifier_string.present?
    if affiliations.present?
      str << " (#{affiliations.join(", ")})"
    end
    str.strip
  end

  def has_active_publications?
    p2p_version_ids = People2publication
                      .where(person_id: self.id)
                      .select(:publication_version_id)
    active_publications = Publication
                          .where(current_version_id: p2p_version_ids)
                          .where(deleted_at: nil)
    # Check if person has active publications
    if active_publications.count == 0
      return false
    else
      return true
    end
  end
  
  # Returns a string representation of all identifiers for person
  def identifier_string
    str = ""
    identifiers.each do |identifier|
      if !str.blank?
        str += ", "
      end
      str << "#{identifier.value}"
    end
    str.strip
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
