# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!


require 'oai'
class OaiProvider < OAI::Provider::Base
  repository_name 'GUP OAI Provider'
  repository_url 'http://gup.ub.gu.se/oai'
  record_prefix 'oai:gup.ub.gu.se'
  admin_email 'gup@ub.gu.se' 
  source_model OAI::Provider::ActiveRecordWrapper.new(Publication)
  #sample_identifier 'oai:pubmedcentral.gov:13900'
end