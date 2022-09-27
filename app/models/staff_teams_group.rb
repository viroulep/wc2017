class StaffTeamsGroup < ApplicationRecord
  belongs_to :staff_team, inverse_of: :staff_teams_groups
  belongs_to :group, inverse_of: :staff_teams_groups
  validates_presence_of :group
  validates_presence_of :staff_team

  delegate :name, to: :staff_team
  delegate :comments, to: :staff_team

  def to_wcif_assignment(generate_assignment_code)
    group.to_wcif_assignment.merge({
      "assignmentCode": generate_assignment_code.call(group.event_id),
    })
  end
end
