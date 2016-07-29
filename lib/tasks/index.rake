namespace :search_index do
  desc "Create search index"
  task index_people: :environment do
  	Person.sync_search_engine
  end
end
