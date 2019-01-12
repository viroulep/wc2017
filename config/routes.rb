Rails.application.routes.draw do
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    resources :public_guests, except: [:show]
    resources :schedule_events, except: [:show]
    resources :rounds, only: [:index, :edit, :update]

    get '/schedule' => 'rounds#schedule'

    get '/wcif' => 'registrations#show_wcif'

    patch 'rounds/add/:event_id' => 'rounds#add', :as => :add_round
    patch 'rounds/remove/:event_id' => 'rounds#remove', :as => :remove_round

    get 'registrations/random' => 'registrations#random'

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

    get 'printing' => 'printing#index'
    get 'printable_schedules' => 'printing#printable_schedules'
    get 'printable_groups' => 'printing#printable_groups'
    get 'printable_groups_only' => 'printing#printable_groups_only'
    get 'printable_groups_schedule' => 'printing#printable_groups_schedule'
    get 'printable_rounds_schedule' => 'printing#printable_rounds_schedule'
    get 'printable_teams' => 'printing#printable_teams'
    get 'rooms_side' => 'printing#rooms_side'

    resources :groups, param: :group_id
    resources :groups, only: [] do
      patch 'staff' => 'groups#update_staff'
    end

    resources :staff_teams do
      get 'schedule' => 'staff_teams#schedule'
    end

    get 'groups-schedule' => 'groups#schedule', :as => :groups_schedule
    get 'groups/e/:event_id' => 'groups#show_for_event', :as => :groups_for_event
    get 'groups/r/:round_id' => 'groups#show_for_round', :as => :groups_for_round
    get 'groups/for_round/:round_id' => 'groups#groups_repartition_for_round', :as => :groups_repartition_for_round
    patch 'groups/move_to/:round_id/(:group_id/:registration_ids)' => 'groups#move_registrations_to_group', :as => :move_to_group
    patch 'groups/drop_group_from/:round_id(/:registration_ids)' => 'groups#drop_groups_from_round', :as => :drop_group_for_round
    patch 'groups/r/:round_id' => 'groups#update_for_round'
    patch 'groups/create_for_round/:round_id' => 'groups#create_groups_for_round', :as => :create_groups_for_round
    patch 'groups/add_everyone_to_all/:round_id' => 'groups#add_everyone_to_all_groups', :as => :fm_mbf_special_fill

    delete 'registration_groups/:id' => 'groups#destroy_registration_group', :as => :delete_from_group

    patch 'groups/autogenerate/:round_id' => 'groups#autogenerate_group', :as => :generate_groups
    get 'groups/generate/:group_id/:direction(/:n)' => 'groups#top_low_to_group', :as => :top_low_groups
    get 'groups/fill/:round_id(/:n)' => 'groups#fill_remaining_groups', :as => :fill_remaining

    post '/confirm' => 'registrations#confirm'
    get '/my_registration' => 'registrations#edit'
    get '/my_schedule' => 'registrations#schedule'

    get '/competition' => 'competitions#show'
    patch '/competition' => 'competitions#update'
    get '/competition/setup' => 'competitions#setup'
    patch '/competition/import/:competition_id' => 'competitions#import_competition', :as => :competition_import
    post '/competition/reset' => 'competitions#reset'
    patch '/competition/import_wcif' => 'competitions#import_wcif', :as => :import_wcif

    root to: 'visitors#index'

    get '/wca_callback' => 'sessions#create'
    get '/signin' => 'sessions#new', :as => :signin
    post '/signin' => 'sessions#signin_with_wca', :as => :signin_with_wca
    get '/wca_down' => 'sessions#anon_staff'
    post '/wca_down' => 'sessions#login_anon_staff'
    get '/signout' => 'sessions#destroy', :as => :signout
  end
end
