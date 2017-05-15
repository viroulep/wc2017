json.extract! round, :id, :start, :end
json.title round.name
json.update_url round_url(round, format: :json)
json.url edit_round_url(round)
