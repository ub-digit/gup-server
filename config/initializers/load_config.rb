# Read config files and store applicable values in APP_CONFIG constant
#main_config = YAML.load_file("#{Rails.root}/config/config.yml")
publication_types_config = YAML.load_file("#{Rails.root}/config/publication_types.yml")
data_sources_config = YAML.load_file("#{Rails.root}/config/data_sources.yml")
categories_config = JSON.parse(File.read("#{Rails.root}/config/categories.json"))
categories_tree_config = JSON.parse(File.read("#{Rails.root}/config/categories_tree.json"))
languages_config = YAML.load_file("#{Rails.root}/config/languages.yml")
if Rails.env == 'test'
  #secret_config = YAML.load_file("#{Rails.root}/config/config_secret.test.yml")
  publication_types_config = YAML.load_file("#{Rails.root}/config/publication_types_test.yml")
  data_sources_config = YAML.load_file("#{Rails.root}/config/data_sources_test.yml")
else
  #secret_config = YAML.load_file("#{Rails.root}/config/config_secret.yml")
end

APP_CONFIG = publication_types_config.merge(data_sources_config).merge(categories_config).merge(categories_tree_config).merge(languages_config)
