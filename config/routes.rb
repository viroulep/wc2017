Rails.application.routes.draw do
  resources :users
  root to: 'visitors#index'
  get '/wca_callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
end
