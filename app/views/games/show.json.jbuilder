json.(game, :id, :active, :active_player_id, :actions_taken)
json.players game.enhanced_players do |player|
  json.(player, :id, :position, :role, :location_staticid, :username)
  json.pretty_role player.pretty_role
  json.cities player.cities do |city|
    json.(city, :color, :density, :name, :population, :staticid)
  end
  json.events player.events
end
json.infections game.individual_infections
json.research_stations game.research_stations_city_static_ids
json.blue_status game.diseases_status.blue
json.black_status game.diseases_status.black
json.yellow_status game.diseases_status.yellow
json.red_status game.diseases_status.red
