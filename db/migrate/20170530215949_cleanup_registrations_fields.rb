class CleanupRegistrationsFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :registrations, :confirmed_at, :datetime
    remove_column :registrations, :confirmed_by, :integer
  end
end
