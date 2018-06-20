json.(game, :id, :active, :active_player_id)
json.players game.enhanced_players do |player|
  json.(player, :role, :position, :city_name)
end
json.infections game.individual_infections
