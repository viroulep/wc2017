class ScrambleEvent < ApplicationRecord
  belongs_to :registration, inverse_of: :scramble_events

  validates_inclusion_of :event_id, in: Event::ALL_EVENTS_BY_ID, message: "%{value} is not a valid event"
end
