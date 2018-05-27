require 'rails_helper'

RSpec.describe StageTwoEpidemic do
  let(:los_angeles) { WorldGraph.cities[1] }
  let(:san_francisco) { WorldGraph.cities[0] }
  let(:game) do
    Fabricate(
      :game,
      nr_of_intensified_cards: 4,
      unused_infection_card_city_staticids: %w{0 1}
    )
  end

  let(:command) { StageTwoEpidemic.new(game: game) }

  it "updates nr of intensified cards to 0" do
    command.call
    expect(game.reload.nr_of_intensified_cards).to eq(0)
  end

  it "infects San Francisco" do
    command.call
    infection = game.infections.find_by(city_staticid: san_francisco.staticid)
    expect(infection.quantity).to eq(1)
  end

  it "infects Los Angeles" do
    command.call
    infection = game.infections.find_by(city_staticid: los_angeles.staticid)
    expect(infection.quantity).to eq(1)
  end

  it "uses two infection cards" do
    command.call
    expect(game.reload.used_infection_card_city_staticids.count).to eq(2)
  end

  it "removes used cards from unused pile" do
    command.call
    expect(game.reload.unused_infection_card_city_staticids.count).to eq(0)
  end

end
