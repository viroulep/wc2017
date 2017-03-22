class AddStatusToRegistrations < ActiveRecord::Migration[5.0]
  def change
    remove_column :registrations, :accepted_at, :string
    remove_column :registrations, :deleted_at, :string
    add_column :registrations, :status, :string
  end
end
