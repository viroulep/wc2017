class StaffTeamMember < ApplicationRecord
  belongs_to :registration
  belongs_to :staff_team

  validates_presence_of :staff_team
  validates_presence_of :registration
end
