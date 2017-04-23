class AddStaffToRegistrationDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_details, :staff, :boolean, default: false
  end
end
