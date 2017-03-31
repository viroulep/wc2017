class CreateGuests < ActiveRecord::Migration[5.0]
  def change
    create_table :guests do |t|
      t.belongs_to :registration, index: true, null: false
      t.string :name

      t.timestamps
    end
  end
end
