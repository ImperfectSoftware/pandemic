require 'rails_helper'

RSpec.describe LineMovementsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  before(:context) do
    @current_user = Fabricate(:user, password: '12341234')
    @game = Fabricate(:game, owner: @current_user)
    @current_player = @current_user.players.find_by(game: @game)
    @player = Fabricate(:player, game: @game)
    @user = @player.user
    @game.update(player_turn_ids: [@current_player.id, @player.id])
  end

  let(:current_player) { @current_user.players.find_by(game: @game) }
  let(:from) { current_player.location_staticid }
  let(:to) { current_player.location.neighbors_staticids.first }

  it 'returns error message if city_staticid is not passed in' do
    post "/games/#{@game.id}/line_movements", params: {}, headers: headers
    expect(error).to eq(I18n.t('player_actions.city_staticid'))
  end

  it 'returns an error if the destination city is not a neighboring city' do
    post "/games/#{@game.id}/line_movements", params: {
      city_staticid: WorldGraph.cities[10].staticid
    }.to_json, headers: headers
    expect(error).to eq(I18n.t('line_movements.destination_is_not_a_neighbor'))
  end

  it 'creates a movement for current player' do
    post "/games/#{@game.id}/line_movements", params: {
      city_staticid: to
    }.to_json, headers: headers
    expect(Movement.last.player).to eq(@current_player)
  end

  it "creates a movement from player's current location" do
    post "/games/#{@game.id}/line_movements", params: {
      city_staticid: to
    }.to_json, headers: headers
    expect(Movement.last.from_city_staticid).to eq(from)
  end

  it 'creates a movement to the location passed in city_staticid' do
    post "/games/#{@game.id}/line_movements", params: {
      city_staticid: to
    }.to_json, headers: headers
    expect(Movement.last.to_city_staticid).to eq(to)
  end

  it 'creates a movement as a player' do
    post "/games/#{@game.id}/line_movements", params: {
      city_staticid: to
    }.to_json, headers: headers
    expect(Movement.last.by_dispatcher).to be(false)
  end

  it "updates player's current location" do
    post "/games/#{@game.id}/line_movements", params: {
      city_staticid: to
    }.to_json, headers: headers
    expect(@current_player.reload.location_staticid).to eq(to)
  end

  it "updates the number of actions taken" do
    post "/games/#{@game.id}/line_movements", params: {
      city_staticid: to
    }.to_json, headers: headers
    expect(@game.reload.actions_taken).to eq(1)
  end
end
