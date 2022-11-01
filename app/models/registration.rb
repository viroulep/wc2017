class Registration < ApplicationRecord
  include WCAModel

  EDIT_GUESTS = true

  belongs_to :user, inverse_of: :registration
  belongs_to :competition
  has_many :guests, inverse_of: :registration
  has_many :scramble_events, inverse_of: :registration
  has_many :registration_groups
  has_many :groups, through: :registration_groups
  has_many :staff_team_members
  has_many :staff_teams, through: :staff_team_members
  has_many :personal_bests, through: :user
  has_one :registration_detail, inverse_of: :registration

  has_many :staff_registrations_groups, inverse_of: :registration
  has_many :staff_teams_groups, through: :staff_teams
  # FIXME: not used?!
  has_many :staff_groups, through: :staff_teams

  accepts_nested_attributes_for :guests, :registration_detail
  # Guests could probably be rewrittent this way too...
  accepts_nested_attributes_for :scramble_events, allow_destroy: true

  delegate :name, to: :user
  delegate :transliterated_name, to: :user
  delegate :country_iso2, to: :user
  delegate :wca_id, to: :user
  delegate :birthdate, to: :user
  delegate :email, to: :user
  delegate :gender, to: :user
  delegate :best_for, to: :user
  delegate :days_helping_as_string, to: :registration_detail
  delegate :activities_as_string, to: :registration_detail

  validate :validate_guests

  scope :accepted, -> { where(status: 'accepted') }

  scope :deleted, -> { where(status: 'deleted') }

  scope :pending, -> { where(status: 'pending') }

  scope :confirmed, -> { includes(:registration_detail).where.not(registration_details: { confirmed_at: nil }) }
  scope :cancelled, -> { includes(:registration_detail).where.not(registration_details: { cancelled_at: nil }) }

  scope :staff_available, -> { joins(:registration_detail).where('registration_details.staff': true) }
  # FIXME: dirty, must be something better
  scope :staff_available_mbf, -> { joins(:registration_detail).where('registration_details.staff=? or registration_details.mbf_judge=?', true, true) }

  scope :without_group_for, -> (round_id) { where.not(id: Group.for_round(round_id).joins(:registrations).select(:'registrations.id')) }

  @@obj_info = %w(id user_id competition_id registrant_id comments status event_ids)

  def any_best_for(event_id)
    (best_for(event_id, "average") || best_for(event_id, "single"))&.best
  end

  def accepted?
    status == 'accepted'
  end

  def staff?
    details.staff
  end

  def pending?
    status == 'pending'
  end

  def deleted?
    status == 'deleted'
  end

  def scrambles_for?(event_id)
    scramble_events.map(&:event_id).include?(event_id)
  end

  def runner_only?
    details.runner_only
  end

  def vg?
    details.vg
  end

  def validate_guests
    unless new_record?
      errors.add(:guests, "Maximum number of guests is 5") if visible_guests.size > 5
    end
  end

  def details
    registration_detail || build_registration_detail
  end

  def get_guest(gid)
    # Get the guest with id 'gid' in the registration's guest, or build a new one
    guests.select { |g| g.id == gid.to_i }.first || guests.build
  end

  def events
    @events ||= event_ids.split(",")
  end

  def doesnt_scramble_events
    @doesnt_scramble_events ||= registration_detail.not_scramble.split(",")
  end

  def warmup_events
    @warmup_events ||= registration_detail.warmup.split(",")
  end

  def days_helping
    @days_helping ||= registration_detail.days_helping.split(",")
  end

  def visible_guests
    guests.reject(&:marked_for_destruction?)
  end

  #def group_for(event_id)
  #event_groups.select { |g| g.event_id == event_id }&.first
  #end

  def to_wcif
    roles = []
    if registration_detail.staff
      roles << "staff"
    end
    if competition.admins_array.include?(self.user_id)
      roles << "organization"
    end
    # individual group assignment
    # TMP hack: without multi submission for scorecards generation
    competitor_groups = self.registration_groups.reject { |rg| rg.group.name =~ /submission/ || (rg.group.event_id == "333mbf" && rg.group.activity_code != "333mbf-r1-a1") }
    competitor_assignment = competitor_groups.map(&:to_wcif_assignment)

    generate_assignment_code = lambda do |event_id|
      if details.runner_only
        "staff-runner"
      elsif scrambles_for?(event_id)
        "staff-scrambler"
      else
        "staff-judgeOrRunner"
      end
    end
    # individual schedule assignment
    individual_staff_assignment = self.staff_registrations_groups.map do |g|
      g.to_wcif_assignment(generate_assignment_code)
    end

    # staff schedule assignments
    staff_team_assignment = self.staff_teams_groups.reject do |g|
      # reject duplicate assignment
      ["333mbf", "444bf", "555bf"].include?(g.group.event_id) && competitor_groups.include?(g.group)
    end.map do |g|
      g.to_wcif_assignment(generate_assignment_code)
    end
    {
      "name": self.name,
      "wcaUserId": self.user_id,
      "wcaId": self.wca_id,
      "registrantId": self.registrant_id,
      "countryIso2": self.country_iso2,
      "gender": self.gender,
      "registration": {
        "wcaRegistrationId": self.id,
        "eventIds": self.events,
        "status": self.status,
      },
      "roles": roles,
      "assignments": (competitor_assignment + individual_staff_assignment + staff_team_assignment).flatten,
      "personalBests": self.personal_bests.map(&:to_wcif),
      "birthdate": self.birthdate,
      "email": self.email,
      #"extensions": {
        #"events_s": scramble_events.map(&:event_id),
        #"events_n": registration_detail.not_scramble.split(","),
        #"events_w": registration_detail.warmup.split(","),
        #"days": registration_detail.days_helping.split(","),
      #},
    }
  end

  def self.filter_collection_for(collection, event_id, *relations)
    # FIXME: yep, would look better with a join in a scope...
    # But I'm too lazy to setup the registration_events table/association.
    all_registrations = relations.empty? ? collection : collection.includes(*relations)
    all_registrations.select { |r| r.events.include?(event_id) }
  end

  def self.with_event_without_group_for(round, *relations)
    filter_collection_for(Registration.accepted.without_group_for(round.id), round.event_id, relations)
  end

  def self.with_event(event_id, *relations)
    filter_collection_for(Registration.accepted, event_id, relations)
  end

  def self.import_registrations(wcif)
    all_users = []
    all_registrations = []
    all_registrations_details = []
    original_registrations_details = RegistrationDetail.all.group_by(&:registration_id)
    all_scramble_events = []
    all_pb = []

    wcif["persons"]&.each do |json_user|
      json_registration = json_user.delete("registration")
      personal_bests = json_user.delete("personalBests")
      json_user = User.process_json(json_user)
      user = User.wca_new(json_user)
      if json_registration
        json_registration["event_ids"] = json_registration.delete("eventIds")&.join(",")
        unless json_registration["id"]
          json_registration["id"] = json_registration["wcaRegistrationId"]
        end
        unless json_registration["id"]
          json_registration["id"] = user.id
        end
        json_registration["user_id"] = json_user["id"]
        json_registration["registrant_id"] = json_user["registrantId"]
        json_registration["competition_id"] = wcif["id"]
        registration_details = original_registrations_details[json_registration["id"]]&.first || RegistrationDetail.new
        attrs = {
          registration_id: json_registration["id"],
          staff: json_user["roles"]&.include?("staff") || registration_details.staff,
          orga: json_user["roles"]&.include?("organization"),
        }
        if json_user["extensions"]
          attrs[:days_helping] = json_user["extensions"]["days"].join(",")
          attrs[:warmup] = json_user["extensions"]["events_w"].join(",")
          attrs[:not_scramble] = json_user["extensions"]["events_n"].join(",")
          attrs[:tshirt] = json_user["extensions"]["t_shirt_size"]
          [:wca_booth, :score_taking, :check_in].each do |key|
            attrs[key] = json_user["extensions"][key.to_s]
          end
        end
        registration_details.assign_attributes(attrs)
        all_registrations_details << registration_details
        if attrs[:staff] && json_user["extensions"]
          json_user["extensions"]["events_s"].each do |eventId|
            se_attr = {
              registration_id: json_registration["id"],
              event_id: eventId,
            }
            all_scramble_events << ScrambleEvent.new(se_attr)
          end
        end

        json_registration.delete("guests")
        all_registrations << Registration.wca_new(json_registration)
      end
      personal_bests&.each do |json_pb|
        user.personal_bests.build(PersonalBest.attrs_from_json(json_pb))
      end
      all_users << user
    end
    if all_users.any?
      # Checking everything all the time is long, let's just clear the table...
      if all_registrations.any?
        # we're importing a wcif with registrations
        # (wcif without registrations can happen, if using myeuro for registrations
        # and the WCA website for the schedule)
        User.delete_all
        PersonalBest.delete_all
        Registration.delete_all
        RegistrationDetail.delete_all
      else
        User.where(id: all_users.map(&:id)).delete_all
        PersonalBest.where(id: all_users.map(&:id)).delete_all
      end
      if all_scramble_events.any?
        # we're importing a wcif with extensions
        ScrambleEvent.delete_all
      end
      ActiveRecord::Base.logger.silence do
        User.import(all_users, recursive: true)
        Registration.import(all_registrations)
        RegistrationDetail.import(all_registrations_details)
        ScrambleEvent.import(all_scramble_events)
      end

      Registration.where("comments ILIKE :search", search: "%staff%").each do |r|
        r.details.staff = true
        r.details.save!(validate: false)
      end
    end
    all_registrations.size
  end
end
