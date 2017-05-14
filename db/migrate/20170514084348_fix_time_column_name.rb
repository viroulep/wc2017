class FixTimeColumnName < ActiveRecord::Migration[5.0]
  def change
    rename_column :groups, :starts_at, :start
    rename_column :groups, :ends_at, :end
    rename_column :rounds, :starts_at, :start
    rename_column :rounds, :ends_at, :end
  end
end
