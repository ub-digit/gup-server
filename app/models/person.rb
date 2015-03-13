require 'active_resource'

class Person < ActiveResource::Base
  attr_accessor :department_name 

  self.site = Rails.application.config.services[:people][:site]
  self.element_name = "person"

  def presentation_string
    str = ""
    str << first_name if respond_to?(:first_name) && first_name.present?
    str << " "
    str << last_name if respond_to?(:last_name) && last_name.present?
    str.strip
  end
  
  def as_json(options = {})
    super(methods: [:presentation_string, :department_name])
  end
end
