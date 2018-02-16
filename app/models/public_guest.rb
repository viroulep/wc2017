class PublicGuest < ApplicationRecord
  # email spec is too hard to validate precisely, use an approximate format
  validates_format_of :email, with: /\A[^@,\s]+@[^@,\s]+\.[^@,\s]+\z/
end
