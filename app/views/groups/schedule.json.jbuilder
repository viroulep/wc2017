json.array! @groups, partial: 'groups/group', as: :group, locals: { display_team_ids: true }
json.array! @schedule_events, partial: 'schedule_events/schedule_event', as: :schedule_event
