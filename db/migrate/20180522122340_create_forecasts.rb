class CreateForecasts < ActiveRecord::Migration[5.1]
  def change
    create_table :forecasts do |t|
      t.integer :game_id
      t.integer :turn_nr

      t.timestamps
    end

    add_index :forecasts, :game_id
  end
end
