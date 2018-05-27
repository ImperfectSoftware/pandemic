class AddGameStatusToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :status, :integer, defaults: 0
  end
end
