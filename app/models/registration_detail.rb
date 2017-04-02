class RegistrationDetail < ApplicationRecord
  belongs_to :registration

  TSHIRT_SIZES = %w(XS S M L XL).freeze
  validates :tshirt, inclusion: { in: TSHIRT_SIZES, message: "%{value} is not a valid size" }
end
