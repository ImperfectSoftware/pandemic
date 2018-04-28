require 'csv'

class WorldGraph
  def self.cities
    @cities ||= [].tap do |cities|
      # Instantiate cities
      CSV.foreach("./db/cities.csv", headers: true) do |row|
        cities << GraphCity
          .new(name: row[1].strip, color: row[2].strip, staticid: row[0])
      end
      # Create Graph
      CSV.foreach("./db/cities.csv", headers: true) do |row|
        city = cities.find { |city| city.name == row[1].strip }
        row[3].split("|").map(&:strip).each do |neighbor_name|
          city.neighbors_names << neighbor_name
        end
      end
    end
  end
end
