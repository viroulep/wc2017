# frozen_string_literal: true

class VenueRoom < ApplicationRecord
  # WCA's blue
  DEFAULT_ROOM_COLOR = "#304a96"
  belongs_to :competition_venue
  has_one :competition, through: :competition_venue
  delegate :start_time, to: :competition
  delegate :end_time, to: :competition
  has_many :rounds, dependent: :destroy
  has_many :schedule_events, dependent: :destroy

  validates :color, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/, message: "Please input a valid hexadecimal color code" }

  before_validation do
    self.color ||= DEFAULT_ROOM_COLOR
  end

  validates_presence_of :name
  validates_numericality_of :wcif_id, only_integer: true

  delegate :timezone, to: :competition_venue

  #def all_activities
    #schedule_activities.flat_map(&:all_activities)
  #end

  def to_wcif
    {
      "id" => wcif_id,
      "name" => name,
      "color" => color,
      "activities" => (rounds + schedule_events).sort_by(&:wcif_id).flat_map(&:to_wcif),
      "extensions" => [],
    }
  end

  def activities_for_date(date)
    groups.select do |a|
      a.start.to_date == date
    end
  end

  def load_wcif!(wcif)
    update!(VenueRoom.wcif_to_attributes(wcif))
    new_rounds = []
    wcif["activities"].each do |activity_wcif|
      parts = ScheduleEvent.parse_activity_code(activity_wcif["activityCode"])
      event = Event.find_or_nil(parts[:event_id])
      if parts[:event_id] == "other"
        round = rounds.find { |r| r.event_id == "magic" } || rounds.build
        new_rounds << round.load_from_other!(activity_wcif)
      elsif event&.attempt_based?
        round = rounds.find { |r| r.r_id == parts[:round_number] && r.event_id == event.id } || rounds.build
        new_rounds << round.load_from_attempt!(activity_wcif)
      else
        round = rounds.find { |r| r.wcif_id == activity_wcif["id"] } || rounds.build
        new_rounds << round.load_wcif!(activity_wcif)
      end
    end
    self.rounds = new_rounds
    self
  end

  def self.wcif_to_attributes(wcif)
    {
      wcif_id: wcif["id"],
      name: wcif["name"],
      color: wcif["color"],
    }
  end
end
