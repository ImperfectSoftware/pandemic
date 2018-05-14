class CreateResearchStations < ActiveRecord::Migration[5.1]
  def change
    create_table :research_stations do |t|
      t.integer :game_id
      t.string :city_staticid

      t.timestamps
    end
  end
end
