class Round < ApplicationRecord
  has_many :groups, inverse_of: :round, dependent: :destroy

  validates_inclusion_of :event_id, in: Event::ALL_EVENTS_BY_ID, message: "%{value} is not a valid event"
  validates_presence_of :r_id, allow_blank: false


  scope :for_event, -> (id) { where(event_id: id) }

  def name
    "#{Event.find(event_id).name} Round #{r_id}"
  end

  def self.all_ordered
    self.all.order(:event_id, :r_id)
  end
end
