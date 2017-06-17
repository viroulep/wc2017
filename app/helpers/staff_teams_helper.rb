module StaffTeamsHelper
  def leaders_to_s(leaders)
    comma = ""
    str = ""
    leaders.each do |l|
      str += comma + l
      comma = ", "
    end
    str
  end
end
