class StaffTeam < ApplicationRecord
  has_many :staff_team_members, inverse_of: :staff_team, dependent: :destroy
  has_many :registrations, through: :staff_team_members
  has_many :scramble_events, through: :registrations
  has_many :users, through: :registrations
  has_many :staff_teams_groups, inverse_of: :staff_team, dependent: :delete_all

  accepts_nested_attributes_for :staff_team_members

  validates_presence_of :name

  def leaders
    staff_team_members.select(&:team_leader).map(&:name)
  end

  def to_wcif
    {
      "name": self.name,
      "comments": self.comments,
      "members": staff_team_members.map(&:to_wcif),
    }
  end

  def team_id
    friendly_id = id
    if name =~ /Team/
      friendly_id = name.sub(/.*(Team #(?<n>[0-9]*).*)/, '#\k<n>')
    end
    friendly_id
  end

  def self.as_resources(user_ids_selected, except_team_ids=[])
    resources = []
    StaffTeam.includes(:users).where.not(id: except_team_ids).order(:name).each do |st|
      selected_users_in_team = st.users.select { |u| user_ids_selected.include?(u.id) }
      if selected_users_in_team.any?
        resources << {
          "id": "team_#{st.id}",
          "title": st.name,
          "children": selected_users_in_team.map do |u|
            {
              id: "#{st.id}-#{u.id.to_s}",
              title: u.name,
            }
          end,
        }
      end
    end
    resources
  end
end
