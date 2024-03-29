class StaffRegistrationsGroup < ApplicationRecord
  REPLACEMENT_TAG = "Replace ".freeze
  belongs_to :registration, inverse_of: :staff_registrations_groups
  belongs_to :group, inverse_of: :staff_registrations_groups
  validates_presence_of :group
  validates_presence_of :registration
  scope :replacements_for, ->(name) { where(role: "#{REPLACEMENT_TAG}#{name}") }

  delegate :name, to: :registration

  def replacement_name
    role&.start_with?(REPLACEMENT_TAG) ? role[REPLACEMENT_TAG.length..-1] : nil
  end

  def to_wcif_assignment(generate_assignment_code)
    {
      "activityId": group.wcif_id,
      "stationNumber": nil,
      "assignmentCode": generate_assignment_code.call(group.event_id),
    }
  end
end
