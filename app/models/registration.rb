class Registration < ApplicationRecord
  include WCAModel
  belongs_to :user
  validates :user, presence: true
  validates :event_ids, presence: true, allow_blank: false
  validates :comments, presence: true, allow_blank: true
  validates :status, presence: true, allow_blank: false

  @@obj_info = %w(id user competition_id comments status event_ids)
end
