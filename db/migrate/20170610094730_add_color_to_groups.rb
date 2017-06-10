class AddColorToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :color, :string
    add_column :staff_registrations_groups, :role, :string
    Group.update_all(color: "white")
  end
end
