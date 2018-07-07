json.cities cities do |city|
  json.(city, :name, :staticid, :color)
end
