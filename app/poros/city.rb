class City

  def self.find(staticid)
    WorldGraph.cities.find do |city|
      city.staticid == staticid
    end
  end

  def self.find_by_name(name)
    WorldGraph.cities.find do |city|
      city.name == name
    end
  end

  def self.find_from_staticids(staticids)
    staticids.map do |staticid|
      find(staticid)
    end.compact
  end

  attr_reader :neighbors_names, :name, :color, :staticid, :population, :density

  def initialize(staticid:, name:, color:, population:, density:)
    @staticid = staticid
    @name = name
    @color = color
    @population = population
    @density = density
    @neighbors_names = []
  end

  def neighbors
    WorldGraph.cities.select do |city|
      neighbors_names.include?(city.name)
    end
  end

  def neighbors_staticids
    neighbors.map(&:staticid)
  end

  def composite_id
    "city-#{staticid}"
  end

  def storable?
    true
  end
end
