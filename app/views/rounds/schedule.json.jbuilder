# FIXME: add real events such as lunch to this!
json.array! @rounds, partial: 'rounds/round', as: :round
json.array! @schedule_events, partial: 'schedule_events/schedule_event', as: :schedule_event
