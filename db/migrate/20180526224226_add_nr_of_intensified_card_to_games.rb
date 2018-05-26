class AddNrOfIntensifiedCardToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :nr_of_intensified_cards, :integer, default: 0
  end
end
