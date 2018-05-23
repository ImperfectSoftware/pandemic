class AddSkipInfectionToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :skip_infection, :boolean, default: false
  end
end
