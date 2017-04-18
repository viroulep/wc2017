class EventGroup < ApplicationRecord
  belongs_to :registration, inverse_of: :event_groups
  has_one :user, through: :registration

  delegate :name, to: :registration

  validates :group, presence: true, allow_blank: false

  validate :registered_for_event
  validate :unique_group

  scope :for_event, -> (id) {
    includes(:registration).where(event_id: id,
                                  registrations: { status: 'accepted' })
  }

  def registered_for_event
    # Note: this also check for event_id validity, as a registration is only using valid event_ids
    errors.add(:event_id, "Competitor is not registered for this event") unless registration.events.include?(event_id)
  end

  # There is only one group for a event/competitor pair
  def unique_group
    all_groups = registration.event_groups.select { |eg| (eg.event_id == event_id && eg.id != id) }
    errors.add(:group, "Competitor is in two groups for #{event_id}!") if all_groups.size > 0
  end
end
