require 'active_resource'

class Person < ActiveResource::Base
  self.site = Rails.application.config.services[:people][:site]
  self.element_name = "person"

  def presentation_string
    "#{first_name} #{last_name}".strip
  end
  
  def as_json(options = {})
    super(methods: [:presentation_string])
  end
end
