class RemoveUidFromUser < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :uid, :string
    remove_column :registrations, :uid, :string
  end
end
