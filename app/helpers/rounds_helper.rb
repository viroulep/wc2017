module RoundsHelper
  def round_colors(round)
    # Random notes: staff color #960505
    total_rounds = Round.where(event_id: round.event_id).count
    if round.event_id == "magic"
      return ["#ccc", "#000"]
    end

    case round.r_id
    when 1
      ["#ffd500", "#000"]
    when 2
      ["#ff5800", "#000"]
    when 3
      ["#c41e3a", "#000"]
    else
      # Should not be possible
      ["#ccc", "#000"]
    end
  end
end
