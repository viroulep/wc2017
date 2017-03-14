class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :wca_id, :string
    add_column :users, :country_iso2, :string
    add_column :users, :email, :string
    add_column :users, :avatar_url, :string
    add_column :users, :avatar_thumb_url, :string
    remove_column :users, :provider
  end
end
