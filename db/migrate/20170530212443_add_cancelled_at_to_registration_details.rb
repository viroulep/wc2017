class AddCancelledAtToRegistrationDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_details, :cancelled_at, :datetime
  end
end
