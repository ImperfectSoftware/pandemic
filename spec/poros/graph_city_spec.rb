require 'rails_helper'

RSpec.describe GraphCity do
  it 'finds a city based on the staticid' do
    city = WorldGraph.cities.sample
    expect(city).to be(GraphCity.find(city.staticid))
  end
end
