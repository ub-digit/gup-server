require 'active_resource'

class Publication < ActiveResource::Base
  self.site = Rails.application.config.services[:publication][:site]
  self.element_name = "publication"
end
