require 'rails_helper'

RSpec.describe City do
  it 'finds a city based on the staticid' do
    city = WorldGraph.cities.sample
    expect(city).to be(City.find(city.staticid))
  end

  it 'formats multi part cities correctly' do
    city = WorldGraph.cities[8]
    expect(city.dashed_name).to eq('new-york')
  end

  it 'formats st petersburg correctly' do
    city = WorldGraph.cities[23]
    expect(city.dashed_name).to eq('st-petersburg')
  end
end
