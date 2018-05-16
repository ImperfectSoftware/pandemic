Fabricator(:player) do
  user { Fabricate(:user) }
  role { Role.all.sample.name }
  current_location_staticid { WorldGraph.cities.first.staticid }
end
