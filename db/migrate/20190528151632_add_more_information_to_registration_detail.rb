class AddMoreInformationToRegistrationDetail < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_details, :score_taking, :boolean, default: false
    add_column :registration_details, :check_in, :boolean, default: false
    add_column :registration_details, :wca_booth, :boolean, default: false
  end
end
