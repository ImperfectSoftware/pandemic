require 'rails_helper'

RSpec.describe Infections do
  let(:los_angeles) { WorldGraph.cities[1] }
  let(:san_francisco) { WorldGraph.cities[0] }
  let(:game) do
    Fabricate(
      :game,
      nr_of_intensified_cards: 4,
      unused_infection_card_city_staticids: %w{0 1},
      discarded_special_player_card_ids: %w{0 0}
    )
  end
  let(:current_player) { game.players.first }
  let(:player) { Fabricate(:player, game: game) }
  let(:command) { Infections.new(game: game) }

  before(:each) do
    current_player.update!(role: Player.roles.keys[0])
    command.call
  end

  it "updates nr of intensified cards to 0" do
    expect(game.reload.nr_of_intensified_cards).to eq(0)
  end

  it "increases the turn nr" do
    expect(game.reload.turn_nr).to eq(2)
  end

  it "infects San Francisco" do
    infection = game.infections.find_by(city_staticid: san_francisco.staticid)
    expect(infection.quantity).to eq(1)
  end

  it "infects Los Angeles" do
    infection = game.infections.find_by(city_staticid: los_angeles.staticid)
    expect(infection.quantity).to eq(1)
  end

  it "uses two infection cards" do
    expect(game.reload.used_infection_card_city_staticids.count).to eq(2)
  end

  it "removes used cards from unused pile" do
    expect(game.reload.unused_infection_card_city_staticids.count).to eq(0)
  end
end
