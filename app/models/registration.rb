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

  @@obj_info = %w(id user_id competition_id comments status event_ids)

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
    competitor_groups = self.groups
    competitor_assignment = competitor_groups.map do |g|
      {
        "activityId": g.id,
        "assignmentCode": "competitor",
      }
    end
    # individual schedule assignment
    individual_staff_assignment = self.staff_registrations_groups.map(&:group).map do |g|
      code = if details.runner_only
               "staff-runner"
             elsif scrambles_for?(g.event_id)
               "staff-scrambler"
             else
               "staff-judge-runner"
             end
      {
        "activityId": g.id,
        "assignmentCode": code,
      }
    end
    # staff schedule affectation
    staff_team_assignment = self.staff_teams_groups.map(&:group).reject do |g|
      # reject duplicate assignment
      ["333mbf", "444bf", "555bf"].include?(g.event_id) && competitor_groups.include?(g)
    end.map do |g|
      code = if details.runner_only
               "staff-runner"
             elsif scrambles_for?(g.event_id)
               "staff-scrambler"
             else
               "staff-judge-runner"
             end
      {
        "activityId": g.id,
        "assignmentCode": code,
      }
    end
    {
      "registrantId": self.id,
      "name": self.name,
      "wcaUserId": self.user_id,
      "wcaId": self.wca_id,
      "countryIso2": self.country_iso2,
      "gender": self.gender,
      "birthdate": self.birthdate,
      "email": self.email,
      "roles": roles,
      "registration": {
        "eventIds": self.events,
        "status": self.status,
      },
      "assignments": (competitor_assignment + individual_staff_assignment + staff_team_assignment).flatten,
      "extensions": {
        "events_s": scramble_events.map(&:event_id),
        "events_n": registration_detail.not_scramble.split(","),
        "events_w": registration_detail.warmup.split(","),
        "days": registration_detail.days_helping.split(","),
      },
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
end
