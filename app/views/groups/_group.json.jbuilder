json.extract! group, :id, :start, :end
json.class "group"
staff ||= nil
group_name = staff ? "[Staff] #{group.name}" : group.name
json.title group_name
bg ||= nil
fg ||= nil
json.color bg if bg
json.textColor fg if fg
json.update_url group_url(group, format: :json) if current_user&.can_manage_competition?(managed_competition)
json.edit_url edit_group_url(group) if current_user&.can_manage_competition?(managed_competition)
