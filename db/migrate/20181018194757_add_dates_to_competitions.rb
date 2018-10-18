class AddDatesToCompetitions < ActiveRecord::Migration[5.0]
  def change
    add_column :competitions, :start_date, :date
    add_column :competitions, :end_date, :date
  end
end
