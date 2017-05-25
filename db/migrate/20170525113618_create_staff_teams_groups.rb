class CreateStaffTeamsGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :staff_teams_groups do |t|
      t.belongs_to :staff_team, index: true, null: false
      t.belongs_to :group, index: true, null: false
    end
    create_table :staff_registrations_groups do |t|
      t.belongs_to :registration, index: true, null: false
      t.belongs_to :group, index: true, null: false
    end
  end
end
