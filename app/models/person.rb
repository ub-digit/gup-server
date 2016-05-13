class Person < ActiveRecord::Base
  has_many :alternative_names
  has_many :identifiers
  has_many :sources, :through => :identifiers
  default_scope { where(deleted_at: nil) }

  validates :last_name, :presence => true

  def as_json(opts={})
    {
      id: id,
      year_of_birth: year_of_birth,
      first_name: first_name,
      last_name: last_name,
      affiliated: affiliated,
      created_at: created_at,
      updated_at: updated_at,
      identifiers: identifiers.as_json,
      alternative_names: alternative_names.as_json,
      #has_active_publications: has_active_publications?
      has_active_publications: true
    }
  end

  # Returns person based on identifier for source
  def self.find_from_identifier(source:, identifier:)
    return find_all_from_identifier(source: source, identifier: identifier).first
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

#  def as_json(options = {})
#    super(methods: [:departments])
#  end
end
