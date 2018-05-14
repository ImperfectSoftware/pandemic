class AddGameIdToInfections < ActiveRecord::Migration[5.1]
  def change
    add_column :infections, :game_id, :integer
    add_index :infections, :game_id
  end
end
