Fabricator(:infection) do
  color { WorldGraph.cities[0].color }
  city_staticid { WorldGraph.cities[0].staticid }
end
