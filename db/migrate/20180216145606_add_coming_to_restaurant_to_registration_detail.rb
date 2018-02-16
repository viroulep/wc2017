class AddComingToRestaurantToRegistrationDetail < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_details, :restaurant_guests, :integer, default: 0
  end
end
