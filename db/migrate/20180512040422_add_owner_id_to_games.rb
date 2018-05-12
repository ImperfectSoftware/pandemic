class AddOwnerIdToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :owner_id, :integer
  end
end
