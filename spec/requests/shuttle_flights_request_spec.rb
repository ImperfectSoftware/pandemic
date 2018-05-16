require 'rails_helper'

RSpec.describe ShuttleFlightsController, type: :request do
  include AuthHelper

  context "with_errors" do
    before(:context) do
      @current_user = Fabricate(:user, password: '12341234')
      @game = Fabricate(:game, owner: @current_user)
      @current_player = @current_user.players.find_by(game: @game)
      @player = Fabricate(:player, game: @game)
      @user = @player.user
      @game.update(player_turn_ids: [@current_player.id, @player.id])
    end

    it "returns error message if it's not the current player's turn" do
      @game.update(turn_nr: 2)
      post "/games/#{@game.id}/shuttle_flights", params: {}, headers: headers
      expect(JSON.parse(response.body)['error'])
        .to eq(I18n.t('player_actions.not_your_turn'))
    end

    it "returns error message if the player has no actions left" do
      @game.update(actions_taken: 4)
      post "/games/#{@game.id}/shuttle_flights", params: {}, headers: headers
      expect(JSON.parse(response.body)['error'])
        .to eq(I18n.t('player_actions.no_actions_left'))
    end

    it 'returns error message if any player has more than 7 city cards' do
      @current_player.update(cards_composite_ids: WorldGraph.composite_ids[0,8])
      post "/games/#{@game.id}/shuttle_flights", params: {}, headers: headers
      expect(JSON.parse(response.body)['error'])
        .to eq(I18n.t('player_actions.discard_player_city_card'))
    end

    it 'returns error message if city_staticid is not passed in' do
      post "/games/#{@game.id}/shuttle_flights", params: {}, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t('shuttle_flights.city_staticid'))
    end

    it 'returns error if player is not currently at a research station' do
      post "/games/#{@game.id}/shuttle_flights", params: {
        city_staticid: WorldGraph.cities.first.staticid
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t('shuttle_flights.departure_city_not_a_research_station'))
    end

    it 'returns error if player is not going to a research station' do
      @game.research_stations
        .create!(city_staticid: @current_player.current_location_staticid)
      post "/games/#{@game.id}/shuttle_flights", params: {
        city_staticid: WorldGraph.cities.second.staticid
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t('shuttle_flights.destination_city_not_a_research_station'))
    end
  end

  context "without errors" do
    before(:context) do
      @current_user = Fabricate(:user, password: '12341234')
      @game = Fabricate(:game, owner: @current_user)
      @current_player = @current_user.players.find_by(game: @game)
      @player = Fabricate(:player, game: @game)
      @user = @player.user
      @game.update(player_turn_ids: [@current_player.id, @player.id])
      @game.research_stations
        .create!(city_staticid: @current_player.current_location_staticid)
      @game.research_stations
        .create!(city_staticid: WorldGraph.cities.second.staticid)
    end

    let(:from) { @current_player.current_location_staticid }
    let(:to) { WorldGraph.cities.second.staticid }

    it 'creates a movement for current player' do
      post "/games/#{@game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(Movement.last.player).to eq(@current_player)
    end

    it "creates a movement from player's current location" do
      post "/games/#{@game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(Movement.last.from_city_staticid).to eq(from)
    end

    it 'creates a movement to the location passed in city_staticid' do
      post "/games/#{@game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(Movement.last.to_city_staticid).to eq(to)
    end

    it 'creates a movement as a player' do
      post "/games/#{@game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(Movement.last.by_dispatcher).to be(false)
    end

    it "updates player's current location" do
      post "/games/#{@game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(@current_player.reload.current_location_staticid).to eq(to)
    end

    it "updates the number of actions taken" do
      post "/games/#{@game.id}/shuttle_flights", params: {
        city_staticid: to
      }.to_json, headers: headers
      expect(@game.reload.actions_taken).to eq(1)
    end
  end
end
