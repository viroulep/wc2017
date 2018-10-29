class Competition < ApplicationRecord
  include WCAModel
  # Group visibility permissions, from the strongest (admin) to the weakest (all)
  GROUPS_VISIBILITIES = %w(admin staff all).freeze
  # List of models to clear up.
  # 'User' is intentionally left there.
  # FIXME: there must be a better way...
  MODEL_USED = [
    Competition, Group, Guest, PersonRoundColor, PersonalBest,
    PublicGuest, RegistrationDetail, RegistrationGroup, Registration,
    Round, ScheduleEvent, ScrambleEvent, StaffRegistrationsGroup,
    StaffTeam, StaffTeamMember, StaffTeamsGroup
  ].freeze

  has_many :registrations

  validates :name, presence: true
  validates :admin_ids, presence: true, allow_blank: false
  validates_inclusion_of :groups_visibility, in: GROUPS_VISIBILITIES

  # NOTE: we *should* be validating start_date <= end_date,
  # but we fetch data from the WCA and we assume it's alright.

  @@obj_info = %w(id name admin_ids start_date end_date)

  def admins_array
    @admins_array ||= admin_ids.split(",").map(&:to_i)
  end

  def number_of_days
    (end_date - start_date).to_i + 1
  end

  def to_wcif
    {
      "formatVersion" => "1.0",
      "id" => id,
      "name" => name,
      "shortName" => name,
      "persons" => registrations.sort_by(&:transliterated_name).map(&:to_wcif),
      "schedule" => {
        # FIXME: hardcoded....
        "startDate": "2018-07-19",
        "numberOfDays": 4,
        "venues": [
          "id": 1,
          "name": "Glass Pavilion",
          "latitudeMicrodegrees": 0,
          "longitudeMicrodegrees": 0,
          "timezone": "Europe/Madrid",
          "rooms": [
            {
              "id": 2,
              "name": "Stage 1",
              "activities": Competition.activities_for_room("blue"),
            },
            {
              "id": 3,
              "name": "Stage 2",
              "activities": Competition.activities_for_room("orange"),
            },
            {
              "id": 4,
              "name": "Stage 3",
              "activities": Competition.activities_for_room("green"),
            },
            {
              "id": 5,
              "name": "Stage 4",
              "activities": Competition.activities_for_room("yellow"),
            },
            {
              "id": 6,
              "name": "Side room",
              "activities": Competition.activities_for_room("white"),
            },
          ],
        ],
      },
      "extensions": {
        "staff_teams": StaffTeam.all.includes(staff_team_members: { registration: :user }).map(&:to_wcif),
      },
    }
  end

  def self.activities_for_room(color)
    associations = {
      round: [],
    }
    timezone = ActiveSupport::TimeZone.new("Europe/Madrid")
    Group.includes(associations).for_color(color).map { |g| g.to_wcif(timezone) }
  end
end
