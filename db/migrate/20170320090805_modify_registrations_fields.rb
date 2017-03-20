class ModifyRegistrationsFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :registrations, :status, :string
    add_column :registrations, :accepted_at, :string
    add_column :registrations, :deleted_at, :string
    add_column :registrations, :competition_id, :string
    add_column :registrations, :comments, :string
    add_column :registrations, :confirmed_at, :datetime
    add_column :registrations, :confirmed_by, :integer
    rename_column :registrations, :events, :event_ids
  end
end
