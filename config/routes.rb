Rails.application.routes.draw do
  resources :public_guests, except: [:show]
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

  get 'printable_schedules' => 'printing#printable_schedules'
  get 'printable_groups' => 'printing#printable_groups'
  get 'printable_groups_schedule' => 'printing#printable_groups_schedule'
  get 'printable_rounds_schedule' => 'printing#printable_rounds_schedule'
  get 'printable_teams' => 'printing#printable_teams'
  get 'staff_lunches' => 'printing#staff_lunches'
  get 'rooms_side' => 'printing#rooms_side'
  get 'registrations_sheet' => 'printing#registrations'

  resources :groups, param: :group_id
  resources :groups, only: [] do
    patch 'staff' => 'groups#update_staff'
  end

  resources :staff_teams

  get 'groups-schedule' => 'groups#schedule', :as => :groups_schedule
  get 'groups/e/:event_id' => 'groups#show_for_event', :as => :groups_for_event
  get 'groups/r/:round_id' => 'groups#show_for_round', :as => :groups_for_round
  patch 'groups/r/:round_id' => 'groups#update_for_round'

  delete 'registration_groups/:id' => 'groups#destroy_registration_group', :as => :delete_from_group

  patch 'groups/autogenerate/:round_id' => 'groups#autogenerate_group', :as => :generate_groups
  get 'groups/generate/:group_id/:direction(/:n)' => 'groups#top_low_to_group', :as => :top_low_groups
  get 'groups/fill/:round_id(/:n)' => 'groups#fill_remaining_groups', :as => :fill_remaining

  post '/confirm' => 'registrations#confirm'
  get '/my_registration' => 'registrations#edit'
  get '/my_schedule' => 'registrations#schedule'

  get '/import_registrations' => 'registrations#import'
  patch '/import_registrations' => 'registrations#import_all'

  root to: 'visitors#index'

  get '/wca_callback' => 'sessions#create'
  get '/signin' => 'sessions#new', :as => :signin
  get '/wca_down' => 'sessions#anon_staff'
  post '/wca_down' => 'sessions#login_anon_staff'
  get '/signout' => 'sessions#destroy', :as => :signout
end
