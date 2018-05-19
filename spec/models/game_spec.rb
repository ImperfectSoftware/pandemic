require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:game) { Fabricate(:game) }

  it 'knows if it has a research station at a specific location' do
    staticid = WorldGraph.cities.first.staticid
    game.research_stations.create!(city_staticid: staticid)
    expect(game.has_research_station_at?(city_staticid: staticid))
      .to be(true)
  end

  context "number of infections for a specific disease" do
    it "returns 0" do
      expect(game.infection_count(color: 'blue')).to eq(0)
    end

    it "returns 5" do
      game.infections.create!(
        city_staticid: WorldGraph.cities.first.staticid,
        quantity: 2,
        color: 'blue'
      )
      game.infections.create!(
        city_staticid: WorldGraph.cities.first.staticid,
        quantity: 3,
        color: 'blue'
      )
      expect(game.infection_count(color: 'blue')).to eq(5)
    end
  end
end
