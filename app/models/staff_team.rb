class StaffTeam < ApplicationRecord
  has_many :staff_team_members, inverse_of: :staff_team, dependent: :destroy
  has_many :registrations, through: :staff_team_members
  has_many :scramble_events, through: :registrations
  has_many :user, through: :registrations
  has_many :staff_teams_groups, inverse_of: :staff_team, dependent: :delete_all

  accepts_nested_attributes_for :staff_team_members

  validates_presence_of :name
end
