require 'active_resource'

class PublicationType < ActiveResource::Base
  self.site = Rails.application.config.services[:publication][:site]
  self.element_name = "publication_type"
end
