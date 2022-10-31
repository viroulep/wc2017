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
    StaffTeam, StaffTeamMember, StaffTeamsGroup, CompetitionVenue, VenueRoom
  ].freeze

  WCIF_ASSOCIATIONS = {
    registrations: {
      groups: [:round],
      staff_registrations_groups: {
        group: [:round],
      },
      staff_teams_groups: {
        group: [:round],
      },
      scramble_events: [],
      competition: [],
      personal_bests: [],
      user: [],
      registration_detail: [],
    },
    competition_venues: {
      venue_rooms: {
        rounds: [:groups],
        schedule_events: [],
      },
    },
  }.freeze


  has_many :registrations
  has_many :competition_venues, dependent: :destroy


  validates :name, presence: true
  validates :admin_ids, presence: true, allow_blank: false
  validates_inclusion_of :groups_visibility, in: GROUPS_VISIBILITIES

  attr_accessor :last_id

  # NOTE: we *should* be validating start_date <= end_date,
  # but we fetch data from the WCA and we assume it's alright.

  @@obj_info = %w(id name admin_ids start_date end_date)

  def admins_array
    @admins_array ||= admin_ids.split(",").map(&:to_i)
  end

  def number_of_days
    (end_date - start_date).to_i + 1
  end

  def start_time
    # Take the easternmost offset
    start_date.to_time.change(offset: "+14:00")
  end

  def end_time
    # Take the westernmost offset
    (end_date + 1).to_time.change(offset: "-12:00")
  end

  def groups_visible_for_all?
    groups_visibility == "all"
  end

  def groups_visible_for_staff?
    groups_visibility == "staff"
  end

  def to_wcif
    {
      "formatVersion" => "1.0",
      "id" => id,
      "name" => name,
      "shortName" => name,
      "persons" => registrations.sort_by { |r| r.registrant_id }.map(&:to_wcif),
      "schedule" => {
        "startDate": start_date,
        "numberOfDays": number_of_days,
        "venues": competition_venues.map(&:to_wcif),
      },
      "extensions": [],
    }
  end

  def self.convert_to_zone_and_strip(datetime_string, tz_string)
    # Fullcalendar will use ambiguously zoned time (ie: will strip the timezone),
    # so we need to store all the datetime in the same timezone
    # (chosen arbitrarily to be UTC).
    # Any external datetime is properly formatted with a timezone (we're the bad guys here),
    # so we need to first convert the datetime to its timezone,
    # then "replace" the zone with UTC without changing the time

    # This turns:
    # Sat, 08 Sep 2018 07:55:00 UTC +00:00
    # into
    # Sat, 08 Sep 2018 09:55:00 CEST +02:00
    itz = DateTime.parse(datetime_string).in_time_zone(tz_string)
    # This turns itz into
    # 2018-09-08 09:55:00 UTC
    ActiveSupport::TimeZone.new("UTC").local_to_utc(itz)
  end

  def self.next_activity_wcif_id
    # ScheduleEvent/Round/Group should be the only sources of activities
    (ScheduleEvent.pluck(:wcif_id) + Round.pluck(:wcif_id) + Group.pluck(:wcif_id)).max + 1
  end

  def import_results(wcif)
    events = wcif["events"]
    return unless events

    events.each do |e|
      e["rounds"].each do |r|
        parts = Group.parse_activity_code(r["id"])
        round = Round.find_by(event_id: parts[:event_id], r_id: parts[:round_number])
        next unless round
        registrant_ids = r["results"].map { |person| person["personId"] }.join(",")
        round.update(registrant_ids: registrant_ids)
      end
    end
  end

  def import_schedule(wcif)
    # TODO: validate the schema!
    schedule = wcif["schedule"]
    return unless schedule

    venues = schedule["venues"]
    return unless venues

    activities = []
    timezone = "UTC"
    new_venues = venues.map do |venue_wcif|
      venue = competition_venues.find { |v| v.wcif_id == venue_wcif["id"] } || competition_venues.build
      venue.load_wcif!(venue_wcif)
    end
    # This also cleans up old venues
    self.competition_venues = new_venues
  end
end
