Fabricator(:research_station) do
  city_staticid { WorldGraph.cities.sample.staticid }
end
