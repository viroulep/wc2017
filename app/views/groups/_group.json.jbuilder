json.extract! group, :id, :start, :end
json.title group.name
json.update_url group_url(group, format: :json)
#json.url group_url(group, format: :json)
