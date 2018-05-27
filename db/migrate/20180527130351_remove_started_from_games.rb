class RemoveStartedFromGames < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :started, :boolean
  end
end
