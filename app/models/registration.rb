class Registration < ApplicationRecord
  include WCAModel

  EDIT_GUESTS = false

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
  has_many :staff_groups, through: :staff_teams

  accepts_nested_attributes_for :guests, :registration_detail
  # Guests could probably be rewrittent this way too...
  accepts_nested_attributes_for :scramble_events, allow_destroy: true

  delegate :name, to: :user
  delegate :best_for, to: :user

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

  def visible_guests
    guests.reject(&:marked_for_destruction?)
  end

  #def group_for(event_id)
    #event_groups.select { |g| g.event_id == event_id }&.first
  #end

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
