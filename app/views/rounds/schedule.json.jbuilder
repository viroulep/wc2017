json.array! @rounds, partial: 'rounds/round', as: :round
json.array! @groups, partial: 'groups/group', as: :group, locals: { fg: '#000' }
json.array! @schedule_events, partial: 'schedule_events/schedule_event', as: :schedule_event
