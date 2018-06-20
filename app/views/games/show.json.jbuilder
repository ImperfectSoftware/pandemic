json.(game, :id, :active, :active_player_id)
json.players game.enhanced_players do |player|
  json.(player, :id, :role, :position, :city_name, :username)
end
json.infections game.individual_infections
