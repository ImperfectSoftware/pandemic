class AddActionsTakenToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :actions_taken, :integer
  end
end
