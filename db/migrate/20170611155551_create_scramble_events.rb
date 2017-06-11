class CreateScrambleEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :scramble_events do |t|
      t.references :registration
      t.string :event_id

      t.timestamps
    end
    add_column :registration_details, :runner_only, :boolean, default: false
  end
end
