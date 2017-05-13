class Group < ApplicationRecord
  has_many :registration_groups, inverse_of: :group, dependent: :delete_all
  has_many :registrations, through: :registration_groups
  has_many :users, through: :registrations

  belongs_to :round

  delegate :event_id, to: :round

  validates_presence_of :name, allow_blank: false
  validates_presence_of :round_id, allow_blank: false

  accepts_nested_attributes_for :registration_groups

  scope :for_round, -> (id) { where(round_id: id) }

  def self.clear_for_round(round_id)
    Group.for_round(round_id).map do |g|
      # There is no :dependent destroy, we can just delete all!
      g.registration_groups.delete_all
    end
  end
end
