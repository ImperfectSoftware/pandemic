require 'rails_helper'

RSpec.describe WorldGraph do

  it 'should contain 48 cities' do
    expect(WorldGraph.cities.count).to be WorldGraph.cities.count
  end

  it 'should have cities with bidirectional neighbors' do
    WorldGraph.cities.each do |city|
      city.neighbors.each do |neighbor|
        expect(neighbor.neighbors_names.include?(city.name)).to be(true),
          "expected #{neighbor.name} to have #{city.name} as neighbor"
      end
    end
  end

  it 'should return composite ids for cities' do
    0.upto(47).each do |position|
      expect(WorldGraph.composite_ids).to include("city-#{position}")
    end
  end

end
