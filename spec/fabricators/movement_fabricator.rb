Fabricator(:movement) do
  from_city_staticid { WorldGraph.cities.first.staticid }
  to_city_staticid { WorldGraph.cities.last.staticid }
end
