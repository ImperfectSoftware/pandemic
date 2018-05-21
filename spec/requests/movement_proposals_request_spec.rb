require 'rails_helper'

RSpec.describe MovementProposalsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user) }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:city) { WorldGraph.cities[20] }
  let(:neighbor) { WorldGraph.cities[1] }

  before(:each) do
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  it "renders an error if city_staticid param is missing" do
    trigger_post(player_id: game.players.first.id)
    expect(error).to eq(I18n.t("errors.missing_param"))
  end

  it "renders an error if player_id param is missing" do
    trigger_post(city_staticid: '2')
    expect(error).to eq(I18n.t("errors.missing_param"))
  end

  context "with no other player in the city" do
    it "returns an error if the city passed in is not a neighbor" do
      trigger_post(player_id: player.id, city_staticid: city.staticid)
      expect(error).to eq(I18n.t("movement_proposals.not_allowed"))
    end
  end

  it "returns an error if the player is not a dispatcher" do
    trigger_post(player_id: player.id, city_staticid: neighbor.staticid)
    expect(error).to eq(I18n.t("dispatcher.must_be_a_dispatcher"))
  end

  context "when destination is a neighbor" do
    before(:each) do
      # dispatcher role
      current_player.update!(role: Player.roles.keys[5])
    end

    it "sets player id on the movement proposal" do
      trigger_post(player_id: player.id, city_staticid: neighbor.staticid)
      expect(MovementProposal.last.player_id).to eq(player.id)
    end

    it "sets creator id on the movement proposal" do
      trigger_post(player_id: player.id, city_staticid: neighbor.staticid)
      expect(MovementProposal.last.creator_id).to eq(current_player.id)
    end

    it "sets accepted to false" do
      trigger_post(player_id: player.id, city_staticid: neighbor.staticid)
      expect(MovementProposal.last.accepted).to be(false)
    end

    it "sets game id on the movement proposal" do
      trigger_post(player_id: player.id, city_staticid: neighbor.staticid)
      expect(MovementProposal.last.game).to eq(game)
    end
  end

  private

  def trigger_post(city_staticid: nil, player_id: nil)
    post "/games/#{game.id}/movement_proposals", params: {
      city_staticid: city_staticid,
      player_id: player_id
    }.to_json, headers: headers
  end
end
