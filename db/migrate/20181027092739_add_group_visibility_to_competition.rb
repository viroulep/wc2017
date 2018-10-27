class AddGroupVisibilityToCompetition < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :groups_visibility, :string, default: Competition::GROUPS_VISIBILITIES.first
  end
end
