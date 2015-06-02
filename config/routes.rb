Rails.application.routes.draw do
  apipie
  resources :users
  resources :session

  namespace :v1, :defaults => {:format => :json} do
    get "fetch_import_data" => "publications#fetch_import_data"
    resources :publications, param: :pubid
    resources :publication_types
    resources :people
    resources :sources

    get "affiliations" => "affiliations#affiliations_for_actor"
  end

end
