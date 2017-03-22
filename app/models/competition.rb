class Competition < ApplicationRecord
  include WCAModel
  has_many :registration

  validates :name, presence: true
  validates :admin_ids, presence: true, allow_blank: false

  @@obj_info = %w(id name admin_ids)
end
