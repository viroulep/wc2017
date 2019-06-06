class RegistrationDetail < ApplicationRecord
  belongs_to :registration

  TSHIRT_SIZES = %w(XS S M L XL XXL XXXL).freeze
  DAYS = %w(Th. Fri. Sa. Su.).freeze
#  validates_inclusion_of :tshirt, in: TSHIRT_SIZES, message: "%{value} is not a valid size"
  validate :is_a_size_or_blank

  private def is_a_size_or_blank
    if !TSHIRT_SIZES.include?(tshirt)
      unless tshirt.blank?
        errors.add(:tshirt, "Not a valid size")
      end
    end
  end

  validates_inclusion_of :staff, in: [true, false]

  validates_numericality_of :mbf1, greater_than_or_equal_to: 0
  #validates_numericality_of :mbf2, greater_than_or_equal_to: 0
  #validates_numericality_of :mbf3, greater_than_or_equal_to: 0

  validates_numericality_of :restaurant_guests, greater_than_or_equal_to: 0

  validate :validates_mbf

  def validates_mbf
    if !registration.events.include?("333mbf") && (mbf1 != 0)
      errors.add(:mbf, "Not registered for mbf")
    end
  end

  def days_helping_as_string
    days_helping.split(",").map { |d| DAYS[d.to_i] }.join(" ")
  end

  def activities_as_string
    activities = []
    activities << "S." if score_taking
    activities << "C." if check_in
    activities << "B." if wca_booth
    activities.join(" ")
  end
end
