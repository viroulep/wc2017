class Guest < ApplicationRecord
  belongs_to :registration, inverse_of: :guests
end
