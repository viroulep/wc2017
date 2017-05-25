class StaffTeamsGroup < ApplicationRecord
  belongs_to :staff_team, inverse_of: :staff_teams_groups
  belongs_to :group, inverse_of: :staff_teams_groups
  validates_presence_of :group
  validates_presence_of :staff_team

  delegate :name, to: :staff_team
end
