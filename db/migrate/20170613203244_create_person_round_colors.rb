class CreatePersonRoundColors < ActiveRecord::Migration[5.0]
  def change
    create_table :person_round_colors do |t|
      t.string :wca_id
      t.string :event_id
      t.integer :color
    end
  end
end
