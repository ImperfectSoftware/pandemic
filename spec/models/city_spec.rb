require 'rails_helper'

RSpec.describe City, type: :model do
  let(:graph_city) { GraphCity.find('1') }

  it "delegates name to graph city" do
    city = City.new(staticid: graph_city.staticid)
    expect(city.name).to eq(graph_city.name)
  end

  it "delegates color to graph city" do
    city = City.new(staticid: graph_city.staticid)
    expect(city.color).to eq(graph_city.color)
  end

  it "delegates population to graph city" do
    city = City.new(staticid: graph_city.staticid)
    expect(city.population).to eq(graph_city.population)
  end

  it "delegates density to graph city" do
    city = City.new(staticid: graph_city.staticid)
    expect(city.density).to eq(graph_city.density)
  end
end
