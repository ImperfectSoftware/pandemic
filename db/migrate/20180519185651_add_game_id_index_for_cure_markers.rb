class AddGameIdIndexForCureMarkers < ActiveRecord::Migration[5.1]
  def change
    add_index :cure_markers, :game_id
  end
end
