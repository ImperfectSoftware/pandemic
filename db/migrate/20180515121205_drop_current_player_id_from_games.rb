class DropCurrentPlayerIdFromGames < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :current_player_id, :integer
    add_column :games, :turn_nr, :integer
  end
end
