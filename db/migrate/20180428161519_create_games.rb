class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.boolean :started
      t.integer :current_player_id
      t.integer :player_turn_ids, array: true 
      t.integer :used_infection_card_city_ids, array: true
      t.integer :unused_infection_card_city_ids, array: true
      t.integer :nr_of_epidemic_cards
      t.integer :discarded_special_player_card_ids, array: true
      t.string :unused_player_card_ids, array: true
      t.integer :number_of_outbreaks

      t.timestamps
    end
  end
end
