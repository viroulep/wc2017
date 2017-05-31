class RegistrationDetail < ApplicationRecord
  belongs_to :registration

  TSHIRT_SIZES = %w(XS S M L XL).freeze
  # TODO: some other time
  # validates_inclusion_of :tshirt, in: TSHIRT_SIZES, message: "%{value} is not a valid size"
  validates_inclusion_of :staff, in: [true, false]
end
