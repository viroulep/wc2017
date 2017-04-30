Rails.application.routes.draw do
  # FIXME: do we even actually need this?!
  #resources :users, only: [:index, :show]

  resources :registrations, only: [:index, :edit, :update] do
    get 'groups' => 'groups#show'
  end

  resources :groups
  get 'groups/e/:event_id' => 'groups#show_for_event', :as => :groups_for_event
  patch 'groups/e/:event_id' => 'groups#update_for_event'
  get 'groups/r/:registration_id' => 'groups#show_for_registration'

  patch '/confirm' => 'registrations#confirm'
  get '/my_registration' => 'registrations#edit'
  get '/my_registration/groups' => 'groups#show_for_registration'

  patch '/import_registrations' => 'registrations#import_all'

  root to: 'visitors#index'

  get '/wca_callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
end
