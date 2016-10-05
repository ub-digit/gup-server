RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # Config copied from http://www.rubydoc.info/gems/factory_girl/file/GETTING_STARTED.md
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      #FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end