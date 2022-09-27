class ScheduleEvent < ApplicationRecord
  #FIXME: remove all this
  belongs_to :venue_room

  def load_wcif!(wcif)
    update!(ScheduleEvent.wcif_to_attributes(wcif, venue_room.timezone))
    self
  end

  def self.parse_activity_code(activity_code)
    parts = activity_code.split("-")
    parts_hash = {
      event_id: parts.shift,
      round_number: nil,
      group_number: nil,
      attempt_number: nil,
    }

    return parts_hash if parts_hash[:event_id] == "other"

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

  def self.wcif_to_attributes(wcif, timezone)
    # NOTE: we intentionally ignore activityCode, we build it later from
    # the round's attribute.
    # We do the same for "name"
    {
      wcif_id: wcif["id"],
      name: wcif["name"],
      activity_code: wcif["activityCode"],
      start: Competition.convert_to_zone_and_strip(wcif["startTime"], timezone),
      end: Competition.convert_to_zone_and_strip(wcif["endTime"], timezone),
    }
  end

  def to_wcif
    tz = ActiveSupport::TimeZone.new(venue_room.timezone)
    {
      id: wcif_id,
      name: name,
      activityCode: activity_code,
      startTime: tz.local_to_utc(self.start).iso8601,
      endTime: tz.local_to_utc(self[:end]).iso8601,
      extensions: [],
    }
  end
end
