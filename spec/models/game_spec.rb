require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game) { Fabricate(:game) }

  it 'knows if it has a research station at a specific location' do
    staticid = WorldGraph.cities.first.staticid
    game.research_stations.create!(city_staticid: staticid)
    expect(game.has_research_station_at?(city_staticid: staticid))
      .to be(true)
  end
end
