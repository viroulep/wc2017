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

  attr_accessor :last_id

  # NOTE: we *should* be validating start_date <= end_date,
  # but we fetch data from the WCA and we assume it's alright.

  @@obj_info = %w(id name admin_ids start_date end_date)
  @@registrant_id = 0

  def self.next_registrant_id
    @@registrant_id += 1
  end

  def admins_array
    @admins_array ||= admin_ids.split(",").map(&:to_i)
  end

  def number_of_days
    (end_date - start_date).to_i + 1
  end

  def groups_visible_for_all?
    groups_visibility == "all"
  end

  def groups_visible_for_staff?
    groups_visibility == "staff"
  end

  def to_wcif
    @@registrant_id = 0
    {
      "formatVersion" => "1.0",
      "id" => id,
      "name" => name,
      "shortName" => name,
      "persons" => registrations.sort_by { |r| r.wca_id || "ZZZZZZZZ" }.map(&:to_wcif),
      "schedule" => {
        "startDate": start_date,
        "numberOfDays": number_of_days,
        "venues": [
          "id": 1,
          "name": "Convention Center",
          "latitudeMicrodegrees": 0,
          "longitudeMicrodegrees": 0,
          "timezone": "Australia/Melbourne",
          "rooms": [
            {
              "id": 2,
              "name": "Stage 1",
              "activities": activities_for_room("blue"),
            },
            {
              "id": 3,
              "name": "Stage 2",
              "activities": activities_for_room("orange"),
            },
            {
              "id": 4,
              "name": "Stage 3",
              "activities": activities_for_room("green"),
            },
            {
              "id": 5,
              "name": "Stage 4",
              "activities": activities_for_room("yellow"),
            },
            {
              "id": 6,
              "name": "Side room",
              "activities": activities_for_room("white"),
            },
          ],
        ],
      },
      #TODO: get events wcif from WCA, and output it here
      "extensions": [
        {
          "id": "groupifier.CompetitionConfig",
          "specUrl": "https://jonatanklosko.github.io/groupifier-next/wcif-extensions/CompetitionConfig.json",
          "data": {
            "localNamesFirst": false,
            "scorecardsBackgroundUrl": "",
            "competitorsSortingRule": "ranks",
            "noTasksForNewcomers": true,
            "tasksForOwnEventsOnly": false
          }
        }
        #"staff_teams": StaffTeam.all.includes(staff_team_members: { registration: :user }).map(&:to_wcif),
      ],
    }
  end

  def activities_for_room(color)
    self.last_id ||= Group.last.id + 1
    associations = {
      round: [],
    }
    timezone = ActiveSupport::TimeZone.new("Australia/Melbourne")
    activity_by_round = Group.includes(associations).for_color(color).group_by { |g| "#{g.event_id}-r#{g.round.r_id}" }
    all_activities = []
    # dirty hack to get scorecards working
    activity_by_round.delete("333mbf-r1")&.each { |g| all_activities << g.to_wcif(timezone) }
    activity_by_round.map do |rid, groups|
      self.last_id += 1
      all_activities << {
        "id": self.last_id,
        "name": rid,
        "activityCode": rid,
        "startTime": nil,
        "endTime": nil,
        "childActivities": groups.map { |g| g.to_wcif(timezone) }
      }
    end
    all_activities
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

  def self.import_schedule(wcif)
    # TODO: validate the schema!
    schedule = wcif["schedule"]
    return unless schedule

    venues = schedule["venues"]
    return unless venues

    activities = []
    timezone = "UTC"
    venues.each do |v|
      # TODO: it supports only one timezone
      timezone = v["timezone"]
      v["rooms"]&.each do |r|
        activities << r["activities"] || []
      end
    end
    # Inserted rounds in the db, filled also with the imported WCIF,
    # other rounds will be deleted (with all their groups and assignments!)
    updated_rounds = Round.where(event_id: "magic").map(&:id)
    ScheduleEvent.destroy_all
    activities.flatten!
    activities.each do |a|
      activity_code = a["activityCode"]
      next unless activity_code
      parts = ScheduleEvent.parse_activity_code(activity_code)
      event = Event.find_or_nil(parts[:event_id])
      fixed_start = convert_to_zone_and_strip(a["startTime"], timezone)
      fixed_end = convert_to_zone_and_strip(a["endTime"], timezone)
      if event
        if parts[:round_number]
          round = Round.where(event_id: event.id, r_id: parts[:round_number]).first
          unless round
            round = Round.create!(event_id: event.id,
                                  r_id: parts[:round_number],
                                  start: fixed_start,
                                  end: fixed_end)
          end
          updated_rounds << round.id
          if parts[:attempt_number]
            unless ["333mbf", "333fm"].include?(event.id)
              raise "FIXME: activity with an attempt number for an unsupported event"
            end
            round.extend_to_include(fixed_start, fixed_end)
            # WARNING, dirty stuff ahead, where we consider that the first 3 groups
            # of the event matches the first 3 attempts!
            all_groups = round.groups.order(:id)
            matching_group = all_groups[parts[:attempt_number]-1]
            if matching_group
              matching_group.update(start: fixed_start, end: fixed_end)
            else
              round.groups.create!(name: a["name"], start: fixed_start, end: fixed_end, color: "white")
            end
          else
            # We can simply update the round (has no effect if we just created it)
            round.update(start: fixed_start, end: fixed_end)
          end
        else
          raise "FIXME: couldn't import a round without a number"
        end
      elsif parts[:event_id] == "other"
        # FIXME: it's impossible to identify existing scheduleevent from the imported
        # events. For this reason, some events requiring staff
        # (such as multi submission, check-in, etc), will be deleted/re-imported
        # no matter what, so I don't make them assignable.
        # Workaround: create "groups" with appropriate names in the "Registration"
        # event (encoded as 'magic' ;)) or the relevant event (333mbf),
        # then affect them (they won't be deleted, because 'magic' is untouched,
        # and 333mbf will still exist), and delete the duplicate ScheduleEvent
        # after re-importing the schedule.
        ScheduleEvent.create!(name: a["name"] || "No name",
                              start: fixed_start,
                              end: fixed_end)
      end
    end
    # Delete rounds which don't exist anymore
    Round.where.not(id: updated_rounds).map(&:destroy)
  end
end
