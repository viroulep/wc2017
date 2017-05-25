class StaffRegistrationsGroup < ApplicationRecord
  belongs_to :registration, inverse_of: :staff_registrations_groups
  belongs_to :group, inverse_of: :staff_registrations_groups
  validates_presence_of :group
  validates_presence_of :registration

  delegate :name, to: :registration
end
