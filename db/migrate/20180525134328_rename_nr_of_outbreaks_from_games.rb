class RenameNrOfOutbreaksFromGames < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :number_of_outbreaks, :integer
    add_column :games, :outbreaks_nr, :integer, default: 0
  end
end
