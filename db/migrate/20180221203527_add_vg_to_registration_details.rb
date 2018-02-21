class AddVgToRegistrationDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_details, :vg, :boolean
  end
end
