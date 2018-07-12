Fabricator(:infection) do
  color { WorldGraph.cities[0].color }
  city_staticid { WorldGraph.cities[0].staticid }
end

Fabricator(:iblue, class_name: Infection) do
  color { 'blue' }
  quantity { 3 }
  game { Game.first }
end

Fabricator(:iyellow, class_name: Infection) do
  color { 'yellow' }
  quantity { 3 }
  game { Game.first }
end
