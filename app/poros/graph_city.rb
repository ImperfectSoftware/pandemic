class GraphCity
  attr_reader :neighbors_names, :name, :color, :staticid

  def initialize(staticid:, name:, color:)
    @staticid = staticid
    @name = name
    @color = color
    @neighbors_names = []
  end

  def neighbors
    WorldGraph.cities.select do |city|
      neighbors_names.include?(city.name)
    end
  end
end
