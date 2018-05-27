Fabricator(:player) do
  user { Fabricate(:user) }
  role { Player.roles.keys.sample }
  location_staticid { WorldGraph.cities.first.staticid }
  cards_composite_ids { WorldGraph.composite_ids[0,7] }
end

Fabricator(:medic, class_name: Player) do
  user { Fabricate(:user) }
  role { Player.roles.keys[2] }
  location_staticid { WorldGraph.cities.first.staticid }
end
