class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :registrations do |t|
      t.belongs_to :user, index: true, unique: true
      t.string :uid
      t.string :status
      t.string :events

      t.timestamps
    end
  end
end
