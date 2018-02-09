source 'https://rubygems.org'

# Use this version of ruby (rvm will use this line)
ruby "2.3.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
group :development, :test do
  gem 'rspec-rails', '~> 3.1'
  gem 'shoulda', '~> 3.5.0'
  gem "factory_girl_rails", "~> 4.0"
  gem 'database_cleaner'
end

group :development do
  gem 'capistrano',  '~> 3.4.0'
  gem 'capistrano-rails', '~> 1.1'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler', '~> 1.1.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  gem 'capistrano-rvm'
end

group :test do
  gem 'webmock'
end

gem 'activeresource'

gem "codeclimate-test-reporter", group: :test, require: nil
gem 'rack-cors'

gem 'apipie-rails'

gem 'nilify_blanks'
gem 'mime-types', '<3.0'
gem 'rest-client'
gem 'nokogiri'
gem 'rsolr'
gem 'will_paginate', '~> 3.0.5'
gem 'spreadsheet'
gem 'oai'
gem 'naturalsort', :require => 'natural_sort_kernel'