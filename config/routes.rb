BBPHealth::Application.routes.draw do

  match "medications/elastic_search" => "medications#elastic_search" 
  resources :medications do
    collection { get :search } 
  end
  
  root :to => "medications#index"
  match "secondary_effects" =>"secondary_effects#index" 
end
