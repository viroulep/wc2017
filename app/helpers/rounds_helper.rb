module RoundsHelper
  def round_colors(round)
    # Random notes: staff color #960505
    total_rounds = Round.where(event_id: round.event_id).count
    if (total_rounds - round.r_id) == 0
      return ["#009e60", "#000"]
    end

    case round.r_id
    when 1
      ["#ffd500", "#000"]
    when 2
      ["#ff5800", "#000"]
    when 3
      ["#c41e3a", "#000"]
    else
      # Lunch break and stuff
      ["#fff", "#000"]
    end
  end
end
