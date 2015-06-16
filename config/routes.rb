Rails.application.routes.draw do
  apipie
  resources :users
  resources :session

  namespace :v1, :defaults => {:format => :json} do
    get "fetch_import_data" => "publications#fetch_import_data"
    
    put "publications/publish/:pubid" => "publications#publish"
    get "publications/:id/review" => "publications#review"

    resources :publications, param: :pubid
    resources :publication_types
    resources :people
    resources :sources
    resources :data_sources
    resources :departments
    resources :categories

    get "affiliations" => "affiliations#affiliations_for_actor"
  end

end
 
