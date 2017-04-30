class CreateStaffTeamMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :staff_team_members do |t|
      t.belongs_to :staff_team, index: true, null: false
      t.belongs_to :registration, index: true, null: false
      t.boolean :team_leader, default: false

      t.timestamps
    end
  end
end
