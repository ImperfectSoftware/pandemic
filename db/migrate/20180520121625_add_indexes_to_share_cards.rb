class AddIndexesToShareCards < ActiveRecord::Migration[5.1]
  def change
    add_index :share_cards, :from_player_id
    add_index :share_cards, :to_player_id
  end
end
