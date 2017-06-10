json.array! @groups, partial: 'groups/group', as: :group
json.array! @schedule_events, partial: 'schedule_events/schedule_event', as: :schedule_event
