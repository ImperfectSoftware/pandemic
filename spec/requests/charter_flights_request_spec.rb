require 'rails_helper'

RSpec.describe CharterFlightsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:user) { user.players.find_by(game: game) }

  before(:each) do
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  it "returns an error if the player doesn't own the current location card" do
    composite_id = WorldGraph.cities[10].composite_id
    current_player.update!(current_location_staticid: WorldGraph.cities.last.staticid)
    post "/games/#{game.id}/charter_flights", params: {
      player_card_composite_id: composite_id
    }.to_json, headers: headers
    expect(error).to eq(I18n.t("charter_flights.player_must_own_card"))
  end

  it "returns an error if no valid player card passed in" do
    post "/games/#{game.id}/charter_flights", params: {}, headers: headers
    expect(error).to eq(I18n.t("player_actions.city_card_composite_id"))
  end

  context "with valid request" do
    let(:city) { WorldGraph.cities[20] }
    let(:composite_id) { city.composite_id }

    before(:each) do
      current_player.update!(
        cards_composite_ids: [current_player.current_location.composite_id]
      )
    end

    it "creates a movement with the to location set to the card passed in" do
      post "/games/#{game.id}/charter_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(Movement.last.to_city_staticid).to eq(city.staticid)
    end

    it "sets movement's from location to the player's current location" do
      location = current_player.current_location
      post "/games/#{game.id}/charter_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(Movement.last.from_city_staticid).to eq(location.staticid)
    end

    it "sets by_dispatcher to false" do
      post "/games/#{game.id}/charter_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(Movement.last.by_dispatcher).to be(false)
    end

    it "sets the current player's location to the new location" do
      post "/games/#{game.id}/charter_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(current_player.reload.current_location).to eq(city)
    end

    it "increments actions taken" do
      post "/games/#{game.id}/charter_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      expect(game.reload.actions_taken).to eq(1)
    end

    it "removes used player card from player's inventory" do
      location = current_player.current_location
      post "/games/#{game.id}/charter_flights", params: {
        player_card_composite_id: composite_id
      }.to_json, headers: headers
      composite_ids = current_player.reload.cards_composite_ids
      expect(composite_ids.include?(location.composite_id)).to be(false)
    end
  end

end
