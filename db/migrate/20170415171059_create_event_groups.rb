class CreateEventGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :event_groups do |t|
      t.belongs_to :registration, index: true, null: false
      t.string :event_id, index: true, null: false
      t.integer :group, index: true, null: false
    end
  end
end
