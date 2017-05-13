Rails.application.routes.draw do
  resources :rounds, only: [:index, :edit, :update]

  patch 'rounds/add/:event_id' => 'rounds#add', :as => :add_round
  patch 'rounds/remove/:event_id' => 'rounds#remove', :as => :remove_round

  resources :registrations, only: [:index, :edit, :update] do
    get 'groups' => 'groups#show_for_registration'
  end

  get 'registrations/psy/:event_id' => 'registrations#psych_sheet'

  resources :groups, except: [:show]
  resources :staff_teams

  get 'groups/e/:event_id' => 'groups#show_for_event', :as => :groups_for_event
  get 'groups/r/:round_id' => 'groups#show_for_round', :as => :groups_for_round
  patch 'groups/r/:round_id' => 'groups#update_for_round'

  patch 'groups/generate/:round_id' => 'groups#autogenerate_group', :as => :generate_groups

  patch '/confirm' => 'registrations#confirm'
  get '/my_registration' => 'registrations#edit'
  get '/my_registration/groups' => 'groups#show_for_registration'

  patch '/import_registrations' => 'registrations#import_all'

  root to: 'visitors#index'

  get '/wca_callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
end
