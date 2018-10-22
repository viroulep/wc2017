class ScheduleEvent < ApplicationRecord
  def self.parse_activity_code(activity_code)
    parts = activity_code.split("-")
    parts_hash = {
      event_id: parts.shift,
      round_number: nil,
      group_number: nil,
      attempt_number: nil,
    }

    parts.each do |p|
      case p[0]
      when "a"
        parts_hash[:attempt_number] = p[1..-1].to_i
      when "g"
        parts_hash[:group_number] = p[1..-1].to_i
      when "r"
        parts_hash[:round_number] = p[1..-1].to_i
      end
    end
    parts_hash
  end
end
