class CreateWcifTables < ActiveRecord::Migration[5.0]
  def change
    create_table :competition_venues do |t|
      t.string :competition_id, null: false, index: true
      t.integer :wcif_id, null: false
      t.string :name, null: false
      t.integer :latitude_microdegrees, null: false
      t.integer :longitude_microdegrees, null: false
      t.string :timezone, null: false
      t.string :country_iso2, null: false
    end
    add_index :competition_venues, [:competition_id, :wcif_id], unique: true

    create_table :venue_rooms do |t|
      t.references :competition_venue, null: false, index: true
      t.integer :wcif_id, null: false
      t.string :name, null: false
      t.string :color, null: false, limit: 7
    end
    add_index :venue_rooms, [:competition_venue_id, :wcif_id], unique: true

    add_reference :rounds, :venue_room
    add_reference :schedule_events, :venue_room
    add_column :rounds, :wcif_id, :integer, null: false
    add_index :rounds, :wcif_id
    add_column :groups, :wcif_id, :integer, null: false
    add_column :groups, :activity_code, :string, null: false
    add_index :groups, :wcif_id
    add_column :schedule_events, :wcif_id, :integer, null: false
    add_column :schedule_events, :activity_code, :string, null: false
    add_index :schedule_events, :wcif_id
    add_column :registrations, :registrant_id, :integer, null: false
  end
end
