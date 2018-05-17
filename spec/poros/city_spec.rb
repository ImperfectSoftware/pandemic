require 'rails_helper'

RSpec.describe City do
  it 'finds a city based on the staticid' do
    city = WorldGraph.cities.sample
    expect(city).to be(City.find(city.staticid))
  end
end
