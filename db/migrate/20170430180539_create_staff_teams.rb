class CreateStaffTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :staff_teams do |t|
      t.string :name

      t.timestamps
    end
  end
end
