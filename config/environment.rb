# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!


require 'oai'
class OaiProvider < OAI::Provider::Base
  repository_name APP_CONFIG['oai_settings']['repository_name']
  repository_url APP_CONFIG['oai_settings']['repository_url']
  record_prefix APP_CONFIG['oai_settings']['record_prefix']
  admin_email APP_CONFIG['oai_settings']['admin_email']
  source_model OAI::Provider::ActiveRecordWrapper.new(Publication.where("deleted_at is null").where("published_at is not null"), {limit: 100})
end
