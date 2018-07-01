json.set! :receive_cities, cities.to_receive
json.set! :give_cities, cities.to_give
json.locations locations do |location|
  json.(location, :name, :staticid)
end
json.airlift_locations airlift_locations do |location|
  json.(location, :name, :staticid)
end
