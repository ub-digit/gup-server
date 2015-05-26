Apipie.configure do |config|
  config.app_name                = "Guppi"
  config.api_base_url            = ""
  config.doc_base_url            = "/apidoc"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
