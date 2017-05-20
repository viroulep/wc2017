json.extract! group, :id, :start, :end
json.title group.name
json.update_url group_url(group, format: :json)
json.edit_url edit_group_url(group) if current_user&.can_manage_competition?(managed_competition)
