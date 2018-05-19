class AddOwnerIdToShareCards < ActiveRecord::Migration[5.1]
  def change
    add_column :share_cards, :creator_id, :integer
    add_index :share_cards, :creator_id
  end
end
