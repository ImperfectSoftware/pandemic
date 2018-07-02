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

  it "knows it has too many cards when composite ids are mixed" do
    composite_ids = WorldGraph.composite_ids[0,7] + ['special-card-3']
    @player.update(cards_composite_ids: composite_ids)
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

  it "knows if it owns the government grant card" do
    composite_id = SpecialCard.events.find(&:government_grant?).composite_id
    @player.cards_composite_ids = [composite_id]
    expect(@player.owns_government_grant?).to eq(true)
  end

  context "card types" do
    let(:city) { WorldGraph.cities.first }
    let(:event) { SpecialCard.events.first }

    before(:each) do
      @player.cards_composite_ids = [city.composite_id, event.composite_id]
    end

    it "knows city cards" do
      expect(@player.cities.count).to eq(1)
    end

    it "knows event cards" do
      expect(@player.events.count).to eq(1)
    end
  end
end
