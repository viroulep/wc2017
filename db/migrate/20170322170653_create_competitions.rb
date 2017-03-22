class CreateCompetitions < ActiveRecord::Migration[5.0]
  def change
    create_table :competitions, id: false do |t|
      t.string :id, primary_key: true
      t.string :name
      t.string :admin_ids

      t.timestamps
    end
  end
end
