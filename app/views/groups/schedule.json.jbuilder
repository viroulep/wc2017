display_id = params[:with_id] == "true"
json.array! @groups, partial: 'groups/group', as: :group, locals: { display_team_ids: display_id }
json.array! @schedule_events, partial: 'schedule_events/schedule_event', as: :schedule_event
