class Registration < ApplicationRecord
  include WCAModel
  belongs_to :user
  validates :user, presence: true
  validates :event_ids, presence: true, allow_blank: false
  validates :comments, presence: true, allow_blank: true
  validates :accepted_at, presence: true, allow_nil: true
  validates :deleted_at, presence: true, allow_nil: true

  @@obj_info = %w(id user competition_id comments accepted_at deleted_at event_ids)
end
