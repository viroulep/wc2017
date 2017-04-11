class AddConfirmedAtToRegistrationDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_details, :confirmed_at, :datetime, default: nil
  end
end
