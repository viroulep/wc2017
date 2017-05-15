json.extract! round, :id, :start, :end
json.title round.name
json.update_url round_url(round, format: :json)
json.url edit_round_url(round) if current_user&.can_manage_competition?(managed_competition)
