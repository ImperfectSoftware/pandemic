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

  it "knows player's current_location" do
    expect(@player.current_location).to be(WorldGraph.cities.first)
  end
end
