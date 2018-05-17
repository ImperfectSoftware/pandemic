require 'rails_helper'

RSpec.describe DirectFlightsController, type: :request do
  include AuthHelper

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:user) { user.players.find_by(game: game) }

  before(:each) do
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  it "returns an error if no player card passed in" do
    post "/games/#{game.id}/direct_flights", params: {}, headers: headers
    expect(JSON.parse(response.body)['error'])
      .to eq(I18n.t("player_actions.city_card_composite_id"))
  end

  it "returns an error if a special player card is passed in" do
    post "/games/#{game.id}/direct_flights", params: {
      player_card_composite_id: SpecialCard.events.first.composite_id
    }.to_json, headers: headers
    expect(JSON.parse(response.body)['error'])
      .to eq(I18n.t("player_actions.city_card_composite_id"))
  end

  context "with valid request" do
    let(:city) { WorldGraph.cities[10] }
    let(:composite_id) { city.composite_id }
    before(:each) do
      current_player.update!(cards_composite_ids: [composite_id])
    end

    it "creates a movement with the to location set to the card passed in" do
      post "/games/#{game.id}/direct_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(Movement.last.to_city_staticid).to eq(city.staticid)
    end

    it "sets movements from location to the player's current location" do
      post "/games/#{game.id}/direct_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(Movement.last.from_city_staticid)
        .to eq(current_player.current_location_staticid)
    end

    it "sets by_dispatcher to false" do
      post "/games/#{game.id}/direct_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(Movement.last.by_dispatcher).to be(false)
    end

    it "sets the current player's location to the new location" do
      post "/games/#{game.id}/direct_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(current_player.reload.current_location)
        .to eq(WorldGraph.cities[10])
    end

    it "increments actions taken" do
      post "/games/#{game.id}/direct_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(game.reload.actions_taken).to eq(1)
    end

    it "removes used player card from player's inventory" do
      post "/games/#{game.id}/direct_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(current_player.reload.cards_composite_ids.include?(composite_id))
        .to be(false)
    end
  end
end
