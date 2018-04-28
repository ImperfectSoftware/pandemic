class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.integer :user_id
      t.string :role
      t.integer :current_location_id
      t.integer :game_id

      t.timestamps
    end

    add_index :players, :user_id
    add_index :players, :current_location_id
    add_index :players, :game_id
  end
end
