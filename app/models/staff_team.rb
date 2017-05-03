class StaffTeam < ApplicationRecord
  has_many :staff_team_members, inverse_of: :staff_team, dependent: :destroy
  has_many :registration, through: :staff_team_members
  has_many :user, through: :registration

  accepts_nested_attributes_for :staff_team_members

  validates_presence_of :name
end
