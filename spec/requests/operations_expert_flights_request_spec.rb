require 'rails_helper'

RSpec.describe OperationsExpertFlightsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:user) { player.user }
  let(:discarded) { WorldGraph.cities.first.staticid }
  let(:destination) { WorldGraph.cities[34].staticid }

  before(:each) do
    current_player.update!(role: Role.all.first.name)
    game.update(player_turn_ids: [current_player.id, player.id])
    game.research_stations
      .create!(city_staticid: current_player.location_staticid)
  end

  it "returns an error if destination param is missing" do
    trigger_post(discarded: discarded)
    expect(error).to eq(I18n.t("errors.missing_param"))
  end

  it "returns an error if discarded param is missing" do
    trigger_post(destination: destination)
    expect(error).to eq(I18n.t("errors.missing_param"))
  end

  it "returns an error if the current player is not an operations expert" do
    current_player.update!(role: Role.all[1,5].sample.name)
    trigger_post(discarded: discarded, destination: destination)
    expect(error).to eq(I18n.t("player_actions.must_be_an_operations_expert"))
  end

  it "returns an error if the departure location is not a research station" do
    current_player
      .update!(location_staticid: WorldGraph.cities[21].staticid)
    trigger_post(discarded: discarded, destination: destination)
    expect(error).to eq(I18n.t(
      'player_actions.city_with_no_station',
      name: current_player.location.name
    ))
  end

  it "returns an error if the player doesn't own the discarded card" do
    current_player.update!(cards_composite_ids: [])
    trigger_post(discarded: discarded, destination: destination)
    expect(error).to eq(I18n.t("player_actions.must_own_card"))
  end

  it "returns an error if this action has already been performed this turn" do
    Fabricate(:operations_expert_action, player: current_player)
    trigger_post(discarded: discarded, destination: destination)
    expect(error).to eq(I18n.t("operations_expert.one_action_per_turn"))
  end

  it "discards the player card" do
    composite_id = current_player.location.composite_id
    trigger_post(discarded: discarded, destination: destination)
    expect(current_player.reload.cards_composite_ids.include?(composite_id))
      .to be(false)
  end

  it "sets the current player's location to destination" do
    trigger_post(discarded: discarded, destination: destination)
    expect(current_player.reload.location.staticid).to eq(destination)
  end

  it "creates a movement with the to location set to the card passed in" do
    trigger_post(discarded: discarded, destination: destination)
    expect(Movement.last.to_city_staticid).to eq(destination)
  end

  it "sets movement's from location to the player's current location" do
    trigger_post(discarded: discarded, destination: destination)
    expect(Movement.last.from_city_staticid)
      .to eq(current_player.location_staticid)
  end

  it "increments actions taken" do
    trigger_post(discarded: discarded, destination: destination)
    expect(game.reload.actions_taken).to eq(1)
  end

  it "creates an action for this turn" do
    trigger_post(discarded: discarded, destination: destination)
    action = current_player.operations_expert_actions
      .find_by(turn_nr: game.turn_nr)
    expect(action.turn_nr).to eq(game.turn_nr)
  end

  private

  def trigger_post(destination: nil, discarded: nil)
    post "/games/#{game.id}/operations_expert_flights", params: {
      discarded_city_staticid: discarded,
      destination_city_staticid: destination
    }.to_json, headers: headers
  end
end
