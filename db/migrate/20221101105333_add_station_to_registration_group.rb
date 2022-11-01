class AddStationToRegistrationGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_groups, :station, :integer, default: nil
  end
end
