json.extract! group, :id, :start, :end
json.class "group"
staff ||= nil
registration ||= @registration
display_team_ids ||= nil
group_name = group.short_name(true)
if staff
  role = "J/R"
  if registration.details.runner_only
    role = "R"
  elsif registration.scrambles_for?(group.event_id)
    role = "S"
  end
  group_name = "[#{role}] " + group_name
end
json.title group_name
json.staff_event staff
bg ||= nil
fg ||= nil
json.color bg ? bg : group.hex_color
json.textColor fg ? fg : group.text_color

if current_user&.can_manage_competition?
  json.update_url group_url(group, format: :json)
  if display_team_ids
    json.title "[#{array_to_s(group.staff_teams.map(&:team_id))}] #{group_name}"
  end
  json.edit_url edit_group_url(group)
end
json.show_url group_url(group)
