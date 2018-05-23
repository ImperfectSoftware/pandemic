class RenameColumnSkipInfectionGames < ActiveRecord::Migration[5.1]
  def change
    rename_column :games, :skip_infection, :skip_infections
  end
end
