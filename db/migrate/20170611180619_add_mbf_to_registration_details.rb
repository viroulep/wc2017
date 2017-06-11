class AddMbfToRegistrationDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_details, :mbf1, :int, default: 0
    add_column :registration_details, :mbf2, :int, default: 0
    add_column :registration_details, :mbf3, :int, default: 0
    add_column :registration_details, :mbf_judge, :boolean, default: false
  end
end
