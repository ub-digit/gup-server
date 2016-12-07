Rails.application.routes.draw do
  apipie
  resources :users
  resources :session

  namespace :v1, :defaults => {:format => :json} do
    get "fetch_import_data" => "publications#fetch_import_data"

    put "publications/publish/:id" => "publications#publish"
    get "publications/review/:id" => "publications#review"
    get "publications/bibl_review/:id" => "publications#bibl_review"
    get "publications/set_biblreview_postponed_until/:id" => "publications#set_biblreview_postponed_until"

    get "publications/feedback_email/:publication_id" => "publications#feedback_email"

    resources :publications, param: :id
    resources :drafts
    resources :published_publications
    get "published_publications_xls" => "published_publications#xls"
    resources :review_publications
    resources :biblreview_publications
    resources :publication_types
    resources :postpone_dates
    resources :faculties
    resources :people
    resources :sources
    resources :data_sources
    resources :series
    resources :projects
    resources :departments
    resources :categories
    resources :languages
    resources :publication_identifier_codes
    resources :userdata, param: :xkonto
    resources :messages, param: :message_type
    resources :reports, param: :name
    resources :feedback_mails
    resources :imports
    resources :asset_data
    resources :publication_records
    resources :person_records
    resources :endnote_files

    get "affiliations" => "affiliations#affiliations_for_actor"
    get "journals" => "journals#search"
    get "public_publication_lists" => "published_publications#index_public"
  
  end

  get "oai" => "oai/oai#index"
  get "rss" => "rss/rss#index"

  # GU Research paths, keep the old scigloo paths
  get "guresearch/lists/publications/guresearch/xml/index.xsql" => "guresearch/general#list_publications"
  get "guresearch/lists/publications/guresearch/xml/researchers.xsql" => "guresearch/general#list_researchers"
  get "guresearch/solr/publications/scigloo" => "guresearch/general#wrap_solr_request"
  get "guresearch/gup/lists/publications/departments/xml/index.xsql" => "guresearch/general#list_publications_special", :defaults => { :param_type => 'departments' }
  get "guresearch/gup/lists/publications/people/xml/index.xsql" => "guresearch/general#list_publications_special", :defaults => { :param_type => 'people' }
  get "guresearch/gup/lists/publications/series/xml/index.xsql" => "guresearch/general#list_publications_special", :defaults => { :param_type => 'series' }
end

