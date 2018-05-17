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

  it "finds a player city card by composite id" do
    composite_id = WorldGraph.cities.first.composite_id
    @player.cards_composite_ids = [composite_id]
    expect(@player.find_player_city_card(composite_id: composite_id))
      .to eq(PlayerCard.find_by_composite_id(composite_id))
  end

  it "returns nil if composite id is for an event card" do
    composite_id = SpecialCard.events.first.composite_id
    @player.cards_composite_ids = [composite_id]
    expect(@player.find_player_city_card(composite_id: composite_id))
      .to be_nil
  end

  it "returns nil if city player card does not belong to the player" do
    composite_id = WorldGraph.cities.first.composite_id
    expect(@player.find_player_city_card(composite_id: composite_id))
      .to be_nil
  end

  it "finds a player event card by composite id" do
    composite_id = SpecialCard.events.first.composite_id
    @player.cards_composite_ids = [composite_id]
    expect(@player.find_player_event_card(composite_id: composite_id))
      .to eq(PlayerCard.find_by_composite_id(composite_id))
  end

  it "returns nil if composite id is for an event card" do
    composite_id = WorldGraph.cities.first.composite_id
    @player.cards_composite_ids = [composite_id]
    expect(@player.find_player_event_card(composite_id: composite_id))
      .to be_nil
  end

  it "returns nil if special player card does not belong to the player" do
    composite_id = SpecialCard.events.first.composite_id
    expect(@player.find_player_event_card(composite_id: composite_id))
      .to be_nil
  end
end
