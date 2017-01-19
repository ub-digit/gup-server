require "pp"
class Person < ActiveRecord::Base
  has_many :alternative_names
  has_many :identifiers
  has_many :sources, :through => :identifiers

  has_many :people2publications
  has_many :publication_versions, :through => :people2publications

  # By this wizardry we can avoid one join (and one distinct):
  has_many :publications, -> { where(deleted_at: nil) }, :through => :people2publications, :source => :current_publication

  has_many :all_publications, :through => :people2publications, :source => :current_publication

  default_scope { where(deleted_at: nil) }
  validates_presence_of :last_name

  #after_save :update_search_engine, on: :create
  #after_save :update_search_engine, on: :update

  def as_json(opts={})
    data = {
      id: id,
      year_of_birth: year_of_birth,
      first_name: first_name,
      last_name: last_name,
      created_at: created_at,
      updated_at: updated_at,
    }
    if opts[:brief]
      data.delete(:created_at)
      data.delete(:updated_at)
    end
    if !opts[:brief]
      data[:identifiers] = identifiers.as_json
      data[:alternative_names] = alternative_names.as_json
    end
    if opts[:include_publication_status]
      data[:has_active_publications] = has_active_publications?
    end
    return data
  end

  #def update_search_engine
  #  if !self.deleted_at
  #    PeopleSearchEngine.update_search_engine([].push(self))
  #  else
  #    PeopleSearchEngine.delete_from_search_engine(self.id)
  #  end
  #end

  # Returns all departments affiliated to this person
  def get_all_departments
    Department.joins(departments2people2publications: {people2publication: {publication_version: :publication}}).where("people2publications.person_id = ?", self.id).where("publications.deleted_at IS NULL").distinct
  end

  # Returns all people based on identifier for source
  def self.find_all_from_identifier(source:, identifier:)
    person_ids = Identifier.joins(:source).where(sources: {name: source}).where(value: identifier).select(:person_id)
    return Person.where(id: person_ids)
  end

  # Return the identifier for a person based om identifier for source
  def get_identifier(source:)
    identifier = Identifier.joins(:source).where(sources: {name: source}).where(person_id: self.id).first
    if identifier
      return identifier.value
    else
      return nil
    end
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
    not self.all_publications.empty?
  end

  def has_affiliations?
    all_publication_version_ids = self.publications.where("published_at is not NULL").select(:current_version_id)
    all_p2p_ids = People2publication.where(publication_version_id: all_publication_version_ids).where(person_id: self.id).select(:id)
    all_department_ids = Departments2people2publication.where(people2publication_id: all_p2p_ids).select(:department_id)
    all_departments = Department.where(id: all_department_ids)

    all_departments.each do |department|
      return true if !department.is_external?
    end
    return false
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
end
