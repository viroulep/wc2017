class Registration < ApplicationRecord
  include WCAModel
  belongs_to :user, inverse_of: :registration
  belongs_to :competition
  has_many :guests, inverse_of: :registration
  has_one :registration_detail, inverse_of: :registration
  accepts_nested_attributes_for :guests, :registration_detail
  validates :user, presence: true
  validates :event_ids, presence: true, allow_blank: false
  validates :comments, presence: true, allow_blank: true
  validates :status, presence: true, allow_blank: false

  @@obj_info = %w(id user competition_id comments status event_ids)

  def details
    registration_detail || build_registration_detail
  end

  def get_guest(gid)
    # Get the guest with id 'gid' in the registration's guest, or build a new one
    guests.select { |g| g.id == gid.to_i }.first || guests.build
  end

  def events
    event_ids.split(",")
  end

  def visible_guests
    guests.reject(&:marked_for_destruction?)
  end
end
