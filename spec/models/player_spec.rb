require 'rails_helper'

RSpec.describe Player, type: :model do
  before(:all) do
    @game = Fabricate(:game)
    @player = @game.players.first
  end

  it 'knows if it has too many cards' do
    @player.update(cards_composite_ids: WorldGraph.composite_ids[0,8])
    expect(@player.has_too_many_cards?).to be(true)
  end

  it 'knows if it has too many cards when player has 9 cards' do
    @player.update(cards_composite_ids: WorldGraph.composite_ids[0,9])
    expect(@player.has_too_many_cards?).to be(true)
  end

  it "knows player's current_location" do
    expect(@player.location).to be(WorldGraph.cities.first)
  end

  it "knows if it owns a card" do
    city = WorldGraph.cities.first
    @player.cards_composite_ids = [city.composite_id]
    expect(@player.owns_card?(city)).to eq(true)
  end
end
