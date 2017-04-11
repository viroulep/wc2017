Rails.application.routes.draw do
  resources :users, only: [:index, :show]

  resources :registrations, only: [:index, :show, :update]
  patch '/confirm' => 'registrations#confirm'
  get '/my_registration' => 'registrations#mine'

  patch '/import_registrations' => 'registrations#import_all'

  root to: 'visitors#index'

  get '/wca_callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
end
