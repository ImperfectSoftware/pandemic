class CreateCities < ActiveRecord::Migration[5.1]
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :color
      t.integer :player_id
      t.integer :game_id
      t.boolean :research_station

      t.timestamps
    end

    add_index :cities, :player_id
    add_index :cities, :game_id
  end
end
