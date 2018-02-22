class Round < ApplicationRecord
  has_many :groups, inverse_of: :round, dependent: :destroy

  validates_inclusion_of :event_id, in: Event::ALL_EVENTS_BY_ID, message: "%{value} is not a valid event"
  validates_presence_of :r_id, allow_blank: false


  scope :for_event, -> (id) { where(event_id: id) }

  before_save :default_values
  def default_values
    self.start ||= DateTime.new(2018, 03, 31, 10, 0, 0)
    self.end ||= DateTime.new(2018, 04, 02, 10, 20, 0)
  end

  def name
    if event_id == "magic"
      "Registration"
    else
      "#{Event.find(event_id).name} Round #{r_id}"
    end
  end

  def self.all_ordered
    self.all.order(:event_id, :r_id)
  end
end
