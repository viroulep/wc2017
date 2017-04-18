class Registration < ApplicationRecord
  include WCAModel
  belongs_to :user, inverse_of: :registration
  belongs_to :competition
  has_many :guests, inverse_of: :registration
  has_many :event_groups, inverse_of: :registration
  has_one :registration_detail, inverse_of: :registration

  accepts_nested_attributes_for :guests, :registration_detail

  delegate :name, to: :user

  validates :user, presence: true
  validates :event_ids, presence: true, allow_blank: false
  validates :comments, presence: true, allow_blank: true
  validates :status, presence: true, allow_blank: false

  validate :validate_guests

  scope :accepted, -> { where(status: 'accepted') }

  scope :deleted, -> { where(status: 'deleted') }

  scope :pending, -> { where(status: 'pending') }

  scope :without_group_for, -> (event_id) { where.not(id: EventGroup.select(:registration_id).where(event_id: event_id)) }

  @@obj_info = %w(id user competition_id comments status event_ids)

  def accepted?
    status == 'accepted'
  end

  def pending?
    status == 'pending'
  end

  def deleted?
    status == 'deleted'
  end

  def validate_guests
    errors.add(:guests, "Maximum number of guests is 5") if visible_guests.size > 5
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

  def self.registered_without_group_for(event_id, *relations)
    filter_collection_for(Registration.accepted.without_group_for(event_id), event_id, relations)
  end

  #def self.with_event(event_id, *relations)
    #filter_collection_for(Registration.all, event_id, relations)
  #end
end
