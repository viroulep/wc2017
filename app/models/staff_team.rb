class StaffTeam < ApplicationRecord
  has_many :staff_team_members
  has_many :registration, through: :staff_team_members
  has_many :user, through: :registration
end
