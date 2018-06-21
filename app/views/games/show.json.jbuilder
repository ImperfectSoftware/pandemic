json.(game, :id, :active, :active_player_id, :actions_taken)
json.players game.enhanced_players do |player|
  json.(player, :id, :role, :position, :city_name, :username)
  json.cities player.cities do |city|
    json.(city, :color, :density, :name, :population, :staticid)
  end
  json.events player.events
end
json.infections game.individual_infections
