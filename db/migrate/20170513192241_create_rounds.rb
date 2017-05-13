class CreateRounds < ActiveRecord::Migration[5.0]
  def change
    create_table :rounds do |t|
      t.integer :r_id
      t.string :event_id, index: true
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end

    add_reference :groups, :round, index: true
    remove_column :groups, :event_id, :string
  end
end
