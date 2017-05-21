json.extract! schedule_event, :start, :end
json.class "schedule_event"
# *dirty* tricky to avoid collision with rounds in the calendar
# has no functional impact, but could avoid weird visual bugs
json.id 2000+schedule_event.id
json.title schedule_event.name
json.color "#ccc"
json.textColor "black"
json.edit_url edit_schedule_event_path(schedule_event, format: :js)
json.update_url schedule_event_path(schedule_event, format: :js)
