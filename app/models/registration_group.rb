class RegistrationGroup < ApplicationRecord
  belongs_to :registration, inverse_of: :registration_groups
  belongs_to :group, inverse_of: :registration_groups
  has_one :user, through: :registration
  validates_presence_of :group
  validates_presence_of :registration

  delegate :name, to: :registration
  delegate :event_id, to: :group

  validate :registered_for_event
  validate :unique_group

  #scope :for_event, -> (id) {
    #includes(:registration).where(event_id: id,
                                  #registrations: { status: 'accepted' })
  #}

  def registered_for_event
    # Note: this also check for event_id validity, as a registration is only using valid event_ids
    errors.add(:registration_id, "Competitor is not registered for this event") unless registration.events.include?(event_id)
  end

  # There is only one group for a event/competitor pair
  def unique_group
    if event_id == "333fm" || event_id == "333mbf"
      return
    end
    #TODO validate against round!
    all_groups = registration.registration_groups.select { |eg| (eg.event_id == event_id && eg.id != id) }
    errors.add(:group_id, "Competitor is in two groups for #{event_id}!") if all_groups.size > 0
  end
end
