require 'active_resource'

class Person < ActiveResource::Base

  self.site = Rails.application.config.services[:people][:site]
  self.element_name = "person"

  def get_latest_affiliations
    Publication.find(:all, :from => "/affiliations", :params => { :person_id => id }).map{|p| p.name}.uniq[0..1]
  end


  def presentation_string
    affiliations = get_latest_affiliations
    str = ""
    str << first_name if respond_to?(:first_name) && first_name.present?
    str << " "
    str << last_name if respond_to?(:last_name) && last_name.present?
    str << ", #{year_of_birth}" if respond_to?(:year_of_birth) && year_of_birth.present?
    if affiliations.present?
      str << " (#{affiliations.join(", ")})"
    end
    str.strip
  end

  def as_json(options = {})
    super(methods: [:presentation_string, :departments])
  end
end
