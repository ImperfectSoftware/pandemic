class ChangeDiscardedCardsType < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :discarded_special_player_card_ids, :integer
    add_column :games, :discarded_special_player_card_ids, :string,
      array: true, default: []
  end
end
