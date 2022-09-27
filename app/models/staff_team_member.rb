class StaffTeamMember < ApplicationRecord
  belongs_to :registration
  belongs_to :staff_team, inverse_of: :staff_team_members

  delegate :name, to: :registration

  validates_presence_of :staff_team
  validates_presence_of :registration

  validate :unique_for_team

  def unique_for_team
    others = staff_team.staff_team_members.where(registration_id: registration_id).reject { |s| s == self }
    errors.add(:registration, "Registration already in the team") if others.any?
  end

  def to_wcif
    {
      "registrantId": registration.registrantId,
      "name": self.name,
      "teamLeader": self.team_leader,
    }
  end
end
