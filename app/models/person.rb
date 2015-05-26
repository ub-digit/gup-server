class Person < ActiveRecord::Base
  has_many :alternative_names
  has_many :identifiers
  has_many :sources, :through => :identifiers

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
      alternative_names: alternative_names.as_json
    }
  end
end

### Old code from GUPPI
  # def get_latest_affiliations
  #   Publication.find(:all, :from => "/affiliations", :params => { :person_id => id }).map{|p| p.name}.uniq[0..1]
  # end


  # def presentation_string
  #   affiliations = get_latest_affiliations
  #   str = ""
  #   str << first_name if respond_to?(:first_name) && first_name.present?
  #   str << " "
  #   str << last_name if respond_to?(:last_name) && last_name.present?
  #   str << ", #{year_of_birth}" if respond_to?(:year_of_birth) && year_of_birth.present?
  #   if affiliations.present?
  #     str << " (#{affiliations.join(", ")})"
  #   end
  #   str.strip
  # end

  # def as_json(options = {})
  #   super(methods: [:presentation_string, :departments])
  # end
