class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :event_id, index: true
      t.datetime :starts_at
      t.datetime :ends_at

      t.timestamps
    end
    remove_column :event_groups, :group, :integer, index: true
    remove_column :event_groups, :event_id, :string, index: true
    add_reference :event_groups, :group, index: true
    rename_table :event_groups, :registration_groups
  end
end
