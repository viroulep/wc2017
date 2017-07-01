Rails.application.routes.draw do
  resources :schedule_events, except: [:show]
  resources :rounds, only: [:index, :edit, :update]

  get '/schedule' => 'rounds#schedule'

  patch 'rounds/add/:event_id' => 'rounds#add', :as => :add_round
  patch 'rounds/remove/:event_id' => 'rounds#remove', :as => :remove_round

  resources :registrations, only: [:index, :edit, :update] do
    get 'groups' => 'groups#show_for_registration'
    get 'schedule' => 'registrations#schedule'
  end

  get 'registrations/staff' => 'registrations#staff'
  get 'registrations/psy/:event_id' => 'registrations#psych_sheet'

  get 'mails' => 'registrations#mails'
  get 'names' => 'registrations#names'
  get 'badges' => 'registrations#badges'
  get 'top3' => 'registrations#top3'
  get 'registrations/cleanup' => 'registrations#cleanup'

  resources :groups, param: :group_id
  resources :groups, only: [] do
    patch 'staff' => 'groups#update_staff'
  end

  resources :staff_teams

  get 'groups-schedule' => 'groups#schedule'
  get 'groups/e/:event_id' => 'groups#show_for_event', :as => :groups_for_event
  get 'groups/r/:round_id' => 'groups#show_for_round', :as => :groups_for_round
  patch 'groups/r/:round_id' => 'groups#update_for_round'

  patch 'groups/generate/:round_id' => 'groups#autogenerate_group', :as => :generate_groups

  post '/confirm' => 'registrations#confirm'
  get '/my_registration' => 'registrations#edit'
  get '/my_schedule' => 'registrations#schedule'

  get '/import_registrations' => 'registrations#import'
  patch '/import_registrations' => 'registrations#import_all'

  root to: 'visitors#index'

  get '/wca_callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/signout' => 'sessions#destroy', :as => :signout
end
