class RemoveCityIdReference < ActiveRecord::Migration[5.1]
  def up
    remove_column :players, :current_location_id
    add_column :players, :current_location_staticid, :string
    remove_column :infections, :city_id
    add_column :infections, :city_staticid, :string
    remove_column :movements, :from_city_id
    add_column :movements, :from_city_staticid, :string
    remove_column :movements, :to_city_id
    add_column :movements, :to_city_staticid, :string
    remove_column :games, :used_infection_card_city_ids
    remove_column :games, :unused_infection_card_city_ids
    add_column :games, :used_infection_card_city_staticids, :string, array: true
    add_column :games, :unused_infection_card_city_staticids, :string, array: true
  end

  def down
  end
end
