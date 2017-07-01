json.extract! round, :id, :start, :end
json.class "round"
json.title round.name
bg, fg = round_colors(round)
json.color bg
json.allDay (round.event_id == "magic")
json.textColor fg
json.update_url round_url(round, format: :json)
json.edit_url edit_round_url(round) if current_user&.can_manage_competition?(managed_competition)
json.groups_url groups_for_round_path(round) if current_user&.can_manage_competition?(managed_competition)
