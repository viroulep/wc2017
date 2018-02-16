class CreatePublicGuests < ActiveRecord::Migration[5.0]
  def change
    create_table :public_guests do |t|
      t.string :fullname
      t.string :email

      t.timestamps
    end
  end
end
