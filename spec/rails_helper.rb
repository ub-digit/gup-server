# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
  config.include Requests::JsonHelpers, :type => :controller
  config.before :each do
    WebMock.disable_net_connect!(allow_localhost: true)
    PeopleSearchEngine.new.clear
    @api_key = APP_CONFIG['api_key_users'].find { |x| x['username'] == 'test_key_user'}['api_key']
    @api_admin_key = APP_CONFIG['api_key_users'].find { |x| x['username'] == 'test_key_admin'}['api_key']
    @xtest_key = APP_CONFIG['api_key_users'].find {|x| x['username'] == 'xtest'}['api_key']
  end
  config.after :each do
    WebMock.allow_net_connect! 
    I18n.locale = I18n.default_locale
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    
    # This is not particularly pretty, but needs to be done,
    # because db/schema.rb does not handle views
    # It might be necessary in the longer perspective to
    # replace db/schema.rb with db/structure.sql instead
    
###     ActiveRecord::Base.connection.execute <<-SQL
### CREATE OR REPLACE VIEW report_views AS
### SELECT p.id AS publication_id,
###        pv.id AS publication_version_id,
###        pv.pubyear AS year,
###        pv.publication_type AS publication_type,
###        pv.content_type AS content_type,
###        d.faculty_id AS faculty_id,
###        d.id AS department_id,
###        p2p.person_id AS person_id,
###        persid.value AS xaccount
### FROM publications p
### INNER JOIN publication_versions pv
###   ON pv.id = p.current_version_id
### INNER JOIN people2publications p2p
###   ON p2p.publication_version_id = pv.id
### INNER JOIN departments2people2publications d2p2p
###   ON d2p2p.people2publication_id = p2p.id
### INNER JOIN departments d
###   ON d.id = d2p2p.department_id
### INNER JOIN people pers
###   ON p2p.person_id = pers.id
### LEFT OUTER JOIN identifiers persid
###   ON pers.id = persid.person_id
### FULL OUTER JOIN sources s
###   ON persid.source_id = s.id
###   AND s.name = 'xkonto'
### WHERE p.deleted_at IS NULL
###   AND p.published_at IS NOT NULL
### SQL
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
