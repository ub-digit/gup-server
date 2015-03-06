require 'active_resource'

class Person < ActiveResource::Base
  self.site = Rails.application.config.services[:people][:site]
  self.element_name = "person"
end
