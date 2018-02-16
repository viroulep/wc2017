class RegistrationDetail < ApplicationRecord
  belongs_to :registration

  TSHIRT_SIZES = %w(XS S M L XL XXL XXXL).freeze
  validates_inclusion_of :tshirt, in: TSHIRT_SIZES, message: "%{value} is not a valid size"
  validates_inclusion_of :staff, in: [true, false]

  validates_numericality_of :mbf1, greater_than_or_equal_to: 0
  #validates_numericality_of :mbf2, greater_than_or_equal_to: 0
  #validates_numericality_of :mbf3, greater_than_or_equal_to: 0

  validate :validates_mbf

  def validates_mbf
    if !registration.events.include?("333mbf") && (mbf1 != 0)
      errors.add(:mbf, "Not registered for mbf")
    end
  end
end
