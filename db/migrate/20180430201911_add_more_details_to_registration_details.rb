class AddMoreDetailsToRegistrationDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :registration_details, :warmup, :string, default: ""
    add_column :registration_details, :not_scramble, :string, default: ""
    add_column :registration_details, :orga, :boolean, default: false
    add_column :registration_details, :days_helping, :string, default: ""
  end
end
