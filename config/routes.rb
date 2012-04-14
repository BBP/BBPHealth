BBPHealth::Application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get '/users/auth/:provider/setup' => 'users/omniauth_callbacks#setup'
    get '/users/auth/facebook/callback' => 'users/omniauth_callbacks#facebook'
  end

  match "medications/elastic_search" => "medications#elastic_search" 
  resources :medications do
    collection do
      get :search 
      get :list
      get :map
    end
  end
  
  root :to => "medications#index"
  match "secondary_effects" =>"secondary_effects#index" 
end
