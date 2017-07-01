json.extract! group, :id, :start, :end
json.class "group"
staff ||= nil
group_name = staff ? "[Staff] #{group.name}" : group.name
json.title group_name
bg ||= nil
fg ||= nil
json.color bg ? bg : group.hex_color
json.textColor fg ? fg : group.text_color

if current_user&.can_manage_competition?(managed_competition)
  json.update_url group_url(group, format: :json)
  json.title "[#{array_to_s(group.staff_teams.map(&:id))}] #{group_name}"
  json.edit_url edit_group_url(group)
end
json.show_url group_url(group)
