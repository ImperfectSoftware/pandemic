require 'rails_helper'

RSpec.describe ShuttleFlightsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:user) { player.user }

  before(:each) do
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  context "with_errors" do

    it 'returns error message if city_staticid is not passed in' do
      post "/games/#{game.id}/shuttle_flights", params: {}, headers: headers
      expect(error).to eq(I18n.t('player_actions.city_staticid'))
    end

    it 'returns error if player is not currently at a research station' do
      post "/games/#{game.id}/shuttle_flights", params: {
        city_staticid: WorldGraph.cities.first.staticid
      }.to_json, headers: headers
      expect(error).to eq(I18n.t(
        'player_actions.city_with_no_station',
        name: WorldGraph.cities.first.name
      ))
    end

    it 'returns error if player is not going to a research station' do
      game.research_stations
        .create!(city_staticid: current_player.location_staticid)
      post "/games/#{game.id}/shuttle_flights", params: {
        city_staticid: WorldGraph.cities.second.staticid
      }.to_json, headers: headers
      expect(error).to eq(I18n.t(
        'player_actions.city_with_no_station',
        name: WorldGraph.cities.second.name
      ))
    end
  end

  context "without errors" do
    let(:from) { current_player.location_staticid }
    let(:to) { WorldGraph.cities.second.staticid }

    before(:each) do
      game.research_stations
        .create!(city_staticid: current_player.location_staticid)
      game.research_stations
        .create!(city_staticid: WorldGraph.cities.second.staticid)
    end

    it 'creates a movement for current player' do
      post "/games/#{game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(Movement.last.player).to eq(current_player)
    end

    it "creates a movement from player's current location" do
      post "/games/#{game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(Movement.last.from_city_staticid).to eq(from)
    end

    it 'creates a movement to the location passed in city_staticid' do
      post "/games/#{game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(Movement.last.to_city_staticid).to eq(to)
    end

    it 'creates a movement as a player' do
      post "/games/#{game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(Movement.last.by_dispatcher).to be(false)
    end

    it "updates player's current location" do
      post "/games/#{game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(current_player.reload.location_staticid).to eq(to)
    end

    it "updates the number of actions taken" do
      post "/games/#{game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(game.reload.actions_taken).to eq(1)
    end
  end
end
