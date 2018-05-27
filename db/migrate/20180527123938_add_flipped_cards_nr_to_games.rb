class AddFlippedCardsNrToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :flipped_cards_nr, :integer, default: 0
  end
end
