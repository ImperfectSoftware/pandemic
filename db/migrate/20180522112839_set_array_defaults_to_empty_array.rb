class SetArrayDefaultsToEmptyArray < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:games, :player_turn_ids, [])
    change_column_default(:games, :discarded_special_player_card_ids, [])
    change_column_default(:games, :unused_player_card_ids, [])
    change_column_default(:games, :used_infection_card_city_staticids, [])
    change_column_default(:games, :unused_infection_card_city_staticids, [])
    change_column_default(:players, :cards_composite_ids, [])
  end
end
