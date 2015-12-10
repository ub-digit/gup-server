# Read config files and store applicable values in APP_CONFIG constant
main_config = YAML.load_file("#{Rails.root}/config/config.yml")
publication_types_config = YAML.load_file("#{Rails.root}/config/publication_types.yml")
data_sources_config = YAML.load_file("#{Rails.root}/config/data_sources.yml")
categories_config = JSON.parse(File.read("#{Rails.root}/config/categories.json"))
faculties_config = JSON.parse(File.read("#{Rails.root}/config/faculties.json"))
categories_tree_config = JSON.parse(File.read("#{Rails.root}/config/categories_tree.json"))
languages_config = YAML.load_file("#{Rails.root}/config/languages.yml")
publication_identifier_codes_config = YAML.load_file("#{Rails.root}/config/publication_identifier_codes.yml")
if Rails.env == 'test'
  secret_config = YAML.load_file("#{Rails.root}/config/config_secret.test.yml")
  publication_types_config = YAML.load_file("#{Rails.root}/config/publication_types_test.yml")
  data_sources_config = YAML.load_file("#{Rails.root}/config/data_sources_test.yml")
else
  secret_config = YAML.load_file("#{Rails.root}/config/config_secret.yml")
end

config = main_config
config = config.merge(secret_config)
config = config.merge(publication_types_config)
config = config.merge(data_sources_config)
config = config.merge(categories_config)
config = config.merge(categories_tree_config)
config = config.merge(languages_config)
config = config.merge(publication_identifier_codes_config)
config = config.merge(faculties_config)

APP_CONFIG = config
