Fabricator(:player) do
  user { Fabricate(:user) }
  role { Player.roles.keys.sample }
  location_staticid { WorldGraph.cities.first.staticid }
  cards_composite_ids { WorldGraph.composite_ids[0,7] }
end
