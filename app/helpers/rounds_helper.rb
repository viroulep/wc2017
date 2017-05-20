module RoundsHelper
  def round_color(round)
    # Random notes: staff color #960505
    total_rounds = Round.where(event_id: round.event_id).count
    if (total_rounds - round.r_id) == 0
      return "#348c1c"
    end

    case round.r_id
    when 1
      "#5b1c8c"
    when 2
      "#1c1c8c"
    when 3
      "#1c8c63"
    else
      # Fullcalendar's default / Lunch break and stuff
      "#3a87ad"
    end
  end
end
