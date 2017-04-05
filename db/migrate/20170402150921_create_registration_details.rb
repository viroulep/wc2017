class CreateRegistrationDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :registration_details do |t|
      t.belongs_to :registration, index: true, null: false
      t.string :tshirt

      t.timestamps
    end
  end
end
