require 'oai'

# Define oai provider class here, it will be implemented just before it is needed for the first time.
class OaiProvider < OAI::Provider::Base
end

class Oai::OaiController < ApplicationController
  def index
    # Remove controller and action from the options.
    options = params.delete_if { |k,v| %w{controller action}.include?(k) }
    setup_oai_provider
    provider = OaiProvider.new
    response =  provider.process_request(options)
    render text: response, content_type: 'text/xml'
  end

private
  # Oai Provider class will be evaluated here, only once.
  def setup_oai_provider
  	@@provider_set ||= false
  	return if @@provider_set
    OaiProvider.class_eval do
      repository_name APP_CONFIG['oai_settings']['repository_name']
      repository_url APP_CONFIG['oai_settings']['repository_url']
      record_prefix APP_CONFIG['oai_settings']['record_prefix']
      admin_email APP_CONFIG['oai_settings']['admin_email']
      source_model OAI::Provider::ActiveRecordWrapper.new(Publication.non_external.published, {limit: APP_CONFIG['oai_settings']['max_no_of_records']})
    end
    OAI::Provider::Base.register_format(OAI::Provider::Metadata::OAI_MODS.instance)
    @@provider_set = true
  end

end
