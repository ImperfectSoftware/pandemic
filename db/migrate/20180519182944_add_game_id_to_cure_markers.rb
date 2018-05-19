class AddGameIdToCureMarkers < ActiveRecord::Migration[5.1]
  def change
    add_column :cure_markers, :game_id, :integer
  end
end
