class AddCommentsToStaffTeam < ActiveRecord::Migration[5.0]
  def change
    add_column :staff_teams, :comments, :text
  end
end
