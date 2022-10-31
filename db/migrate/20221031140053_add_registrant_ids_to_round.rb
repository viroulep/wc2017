class AddRegistrantIdsToRound < ActiveRecord::Migration[5.0]
  def change
    add_column :rounds, :registrant_ids, :string, default: "", null: false
  end
end
