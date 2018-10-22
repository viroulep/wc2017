class Round < ApplicationRecord
  include ApplicationHelper
  has_many :groups, inverse_of: :round, dependent: :destroy

  validates_inclusion_of :event_id, in: Event::ALL_EVENTS_BY_ID, message: "%{value} is not a valid event"
  validates_presence_of :r_id, allow_blank: false


  scope :for_event, -> (id) { where(event_id: id) }

  before_save :default_values
  def default_values
    self.start ||= managed_competition.start_date.to_datetime.change(hour: 10)
    self.end ||= managed_competition.start_date.to_datetime.change(hour: 12)
  end

  before_save :move_groups, if: :start_changed?, unless: :new_record?
  before_save :cut_groups, if: :end_changed?, unless: :new_record?

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
      "Registration"
    else
      "#{Event.find(event_id).name} Round #{r_id}"
    end
  end

  def extend_to_include(start_time, end_time)
    any_change = false
    if start_time < self.start
      self.start = start_time
      any_change = true
    end
    if end_time > self.end
      self.end = end_time
      any_change = true
    end
    self.save! if any_change
  end

  def self.all_ordered
    self.all.order(:event_id, :r_id)
  end
end
