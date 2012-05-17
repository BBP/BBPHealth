BBPHealth::Application.routes.draw do

  scope "(:locale)", :locale => /en|fr/,  :defaults => {:locale => ""} do
    devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
    devise_scope :user do
      get '/users/auth/:provider/setup'   => 'users/omniauth_callbacks#setup'
      get '/users/auth/facebook/callback' => 'users/omniauth_callbacks#facebook'
    end

    resources :medications do
      collection do
        get :search 
        get :list
        get :elastic_search
      end
      member do
        get :map
      end
      resources :secondary_effects
    end
    
    root :to => "medications#index"
    match "secondary_effects" =>"secondary_effects#index" 
  end

  get '/map/:id/clusterize' => 'map#clusterize'
  get '/map/:id/select'     => 'map#select'
end
