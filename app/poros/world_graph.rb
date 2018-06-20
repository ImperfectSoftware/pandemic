class WorldGraph
  def self.cities
    @cities ||= [].tap do |cities|
      # Instantiate cities
      CSV.foreach("./db/cities.csv", headers: true) do |row|
        cities << City.new(
          name: row[1].strip,
          color: row[4].strip,
          staticid: row[0],
          population: row[2].to_i,
          density: row[3].strip,
        )
      end
      # Create Graph
      CSV.foreach("./db/cities.csv", headers: true) do |row|
        city = cities.find { |city| city.name == row[1].strip }
        row[5].split("|").map(&:strip).each do |neighbor_name|
          city.neighbors_names << neighbor_name
        end
      end
    end
  end

  def self.composite_ids
    @composite_ids ||= self.cities.map(&:composite_id)
  end
end
