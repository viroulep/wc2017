class Group < ApplicationRecord
  has_many :registration_groups, inverse_of: :group, dependent: :destroy
  has_many :registrations, through: :registration_groups
  has_many :users, through: :registrations

  validates_inclusion_of :event_id, in: Event::ALL_EVENTS_BY_ID, message: "%{value} is not a valid event"
  validates_presence_of :name, allow_blank: false

  accepts_nested_attributes_for :registration_groups

  scope :for_event, -> (id) { where(event_id: id) }

end
