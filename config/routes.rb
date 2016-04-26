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
    resources :publication_types
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
    resources :reports

    get "affiliations" => "affiliations#affiliations_for_actor"

    get "journals" => "journals#search"
  end

end
 
