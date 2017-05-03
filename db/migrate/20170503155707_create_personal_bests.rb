class CreatePersonalBests < ActiveRecord::Migration[5.0]
  def change
    create_table :personal_bests do |t|
      t.belongs_to :user, index: true, null: false
      t.string :result_type, null: false
      t.string :event_id, index: true, null: false
      t.integer :best, null: false, default: 0
      t.integer :world_ranking, null: false, default: 0
      t.integer :continental_ranking, null: false, default: 0
      t.integer :national_ranking, null: false, default: 0
    end
  end
end
