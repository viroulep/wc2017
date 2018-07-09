class StaffRegistrationsGroup < ApplicationRecord
  belongs_to :registration, inverse_of: :staff_registrations_groups
  belongs_to :group, inverse_of: :staff_registrations_groups
  validates_presence_of :group
  validates_presence_of :registration
  scope :replacements_for, ->(name) { where(role: "Replace #{name}") }

  delegate :name, to: :registration
end
