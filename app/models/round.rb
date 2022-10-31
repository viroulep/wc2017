class Round < ApplicationRecord
  include ApplicationHelper
  has_many :groups, inverse_of: :round, dependent: :destroy
  belongs_to :venue_room

  validates_inclusion_of :event_id, in: Event::ALL_EVENTS_BY_ID, message: "%{value} is not a valid event"
  validates_presence_of :r_id, allow_blank: false


  scope :for_event, -> (id) { where(event_id: id) }

  delegate :color, to: :venue_room

  before_save :default_values
  def default_values
    self.start ||= managed_competition.start_date.to_datetime.change(hour: 10)
    self.end ||= managed_competition.start_date.to_datetime.change(hour: 12)
  end

  before_save :move_groups, if: :start_changed?, unless: :new_record?
  before_save :cut_groups, if: :end_changed?, unless: :new_record?

  def load_wcif!(wcif)
    update!(Round.wcif_to_attributes(wcif, venue_room.timezone))
    puts "#{wcif["childActivities"].size} child activities"
    # TODO: import nested groups/activities (or not...)
    self
  end

  def registrant_ids_array
    registrant_ids.split(",").map(&:to_i)
  end

  def event
    Event.find(event_id)
  end

  def activity_code
    "#{event_id}-r#{r_id}"
  end

  def load_from_attempt!(wcif)
    attrs = Round.wcif_to_attributes(wcif, venue_room.timezone)
    # NOTE: dirty hack, for these rounds we just want to hide them and give
    # them "id" 0.
    activity_id = attrs.delete(:wcif_id)
    attrs[:wcif_id] = 0
    new_record? ? update!(attrs) : extend_to_include!(attrs[:start], attrs[:end])
    # NOTE: dirty hack, we consider such events have only one group :s
    parts = Group.parse_activity_code(wcif["activityCode"])
    g = groups.find { |g| g.wcif_id == activity_id } || groups.build
    group_attrs = {
      name: "#{name}, Attempt #{parts[:attempt_number]}",
      wcif_id: activity_id,
      activity_code: wcif["activityCode"],
      start: attrs[:start],
      end: attrs[:end],
      color: "blue",
    }
    g.update!(group_attrs)
    self
  end

  def load_from_other!(wcif)
    attrs = {
      wcif_id: 0,
      event_id: "magic",
      r_id: 1,
      start: Competition.convert_to_zone_and_strip(wcif["startTime"], venue_room.timezone),
      end: Competition.convert_to_zone_and_strip(wcif["endTime"], venue_room.timezone),
    }
    new_record? ? update!(attrs) : extend_to_include!(attrs[:start], attrs[:end])
    g = groups.find { |g| g.wcif_id == wcif["id"] } || groups.build
    group_attrs = {
      name: wcif["name"],
      wcif_id: wcif["id"],
      activity_code: wcif["activityCode"],
      start: attrs[:start],
      end: attrs[:end],
      color: "blue",
    }
    g.update!(group_attrs)
    self
  end

  def move_groups
    # If we move a round around, we also need to move its groups
    diff_in_seconds = start - start_was
    groups.each do |g|
      g.update(start: g.start + diff_in_seconds, end: g.end + diff_in_seconds)
    end
  end

  def cut_groups
    # We shrinked or extended the round.
    # If some groups start/end *after* the end, we need to put them back within the
    # round boundaries
    groups.each do |g|
      if g.end > self[:end]
        group_duration = g.end - g.start
        shift_needed = g.end - self[:end]
        g.start -= shift_needed
        g.end -= shift_needed
        g.start = start if g.start < start
        g.save!
      end
    end
  end

  def name
    if event_id == "magic"
      "Placeholder round for generic tasks"
    else
      "#{Event.find(event_id).name}, Round #{r_id}"
    end
  end

  def extend_to_include!(start_time, end_time)
    attrs = {
    }
    if start_time < self.start
      attrs[:start] = start_time
    end
    if end_time > self.end
      attrs[:end] = end_time
    end
    # Skip callbacks because we don't want to trigger callbacks which
    # move groups around!
    update_columns(attrs) unless attrs.empty?
  end

  def self.all_ordered
    self.all.order(:event_id, :r_id)
  end

  def self.wcif_to_attributes(wcif, timezone)
    # NOTE: we intentionally ignore activityCode, we build it later from
    # the round's attribute.
    # We do the same for "name"
    parts = Group.parse_activity_code(wcif["activityCode"])
    {
      wcif_id: wcif["id"],
      event_id: parts[:event_id],
      r_id: parts[:round_number],
      start: Competition.convert_to_zone_and_strip(wcif["startTime"], timezone),
      end: Competition.convert_to_zone_and_strip(wcif["endTime"], timezone),
    }
  end

  def to_wcif
    children = groups.sort_by(&:start)
    tz = ActiveSupport::TimeZone.new(venue_room.timezone)
    # The "magic" round holds all "other" stuff ;)
    # For these we don't want to emit the actual round, we want to emit
    # the attempts/actual events.
    if event.attempt_based? || event.magic?
      children.map { |g| g.to_wcif(tz) }
    else
      {
        id: wcif_id,
        name: name,
        startTime: tz.local_to_utc(self.start).iso8601,
        endTime: tz.local_to_utc(self[:end]).iso8601,
        activityCode: activity_code,
        childActivities: children.map { |g| g.to_wcif(tz) },
        extensions: [],
      }
    end
  end
end
