require 'rails_helper'

RSpec.describe PlayerCard do
  it 'finds a city' do
    city = WorldGraph.cities.sample
    expect(city).to be(PlayerCard.find_by_composite_id(city.composite_id))
  end

  it 'finds a special card' do
    event = SpecialCard.events.sample
    expect(event).to be(PlayerCard.find_by_composite_id(event.composite_id))
  end
end
