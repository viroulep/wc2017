json.extract! group, :id, :start, :end
json.class "group"
staff ||= nil
registration ||= @registration
display_team_ids ||= nil
group_name = group.short_name(true)
json.title "#{group_name} (#{array_to_s(group.staff_teams.map(&:leaders).map(&:first).map { |name| name.partition(" ").first })})"
bg ||= nil
fg ||= nil
json.color bg ? bg : group.hex_color
json.textColor fg ? fg : group.text_color

