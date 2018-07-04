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

Fabricator(:not_a_researcher, class_name: Player) do
  user { Fabricate(:user) }
  role do
    roles = Player.roles.keys
    roles.delete('researcher')
    roles.sample
  end
  location_staticid { WorldGraph.cities.first.staticid }
end

Fabricator(:quarantine_specialist, class_name: Player) do
  user { Fabricate(:user) }
  role { Player.roles.keys[4] }
  location_staticid { WorldGraph.cities.first.staticid }
end

Fabricator(:operations_expert, class_name: Player) do
  user { Fabricate(:user) }
  role { Player.roles.keys[0] }
  location_staticid { WorldGraph.cities.first.staticid }
end
