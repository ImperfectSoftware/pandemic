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

  context "when creating a proposal" do

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

    it "creates a movement proposal if using an airlift card" do
      airlift = SpecialCard.events.find(&:airlift?)
      current_player.update!(cards_composite_ids: [airlift.composite_id])
      trigger_post(
        player_id: player.id,
        city_staticid: neighbor.staticid,
        airlift: true
      )
      expect(MovementProposal.last.player_id).to eq(player.id)
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
  end

  context "when updating a proposal" do
    let(:other_player) { Fabricate(:player, game: game) }
    let(:movement_proposal) do
      Fabricate(
        :movement_proposal,
        game: game,
        player: current_player,
        creator: player,
        city_staticid: neighbor.staticid
      )
    end

    before(:each) do
      game.update(player_turn_ids: [
        current_player.id,
        player.id,
        other_player.id
      ])
    end

    it "errors out if not the same turn nr" do
      game.increment!(:turn_nr)
      trigger_put
      expect(error).to eq(I18n.t("movement_proposals.expired"))
    end

    it "error if current player is not the player proposal was created for" do
      movement_proposal.update!(player: other_player)
      trigger_put
      expect(error).to eq(I18n.t("errors.not_authorized"))
    end

    it "returns an error unless there is one action left" do
      game.update!(actions_taken: 4)
      trigger_put
      expect(error).to eq(I18n.t("player_actions.no_actions_left"))
    end

    it "returns error if player is no longer neighboring the city" do
      movement_proposal.update!(city_staticid: city.staticid)
      trigger_put
      expect(error).to eq(I18n.t("movement_proposals.not_allowed"))
    end

    it "increments actions by one" do
      trigger_put
      expect(game.reload.actions_taken).to eq(1)
    end

    it "updates accepted to true" do
      trigger_put
      expect(movement_proposal.reload.accepted).to be(true)
    end

    it "sets player to puppet_player" do
      trigger_put
      expect(Movement.last.player_id).to eq(current_player.id)
    end

    it "sets from to puppet_player's initial location" do
      trigger_put
      expect(Movement.last.from_city_staticid)
        .to eq(current_player.location.staticid)
    end

    it "sets to location to puppet_player's destination" do
      trigger_put
      expect(Movement.last.to_city_staticid)
        .to eq(current_player.reload.location.staticid)
    end

    it "updates the current player's location" do
      trigger_put
      expect(current_player.reload.location.staticid)
        .to eq(movement_proposal.city_staticid)
    end

    it "does nothing if accepted param is false"do
      trigger_put(accepted: false)
      expect(movement_proposal.reload.accepted).to be(false)
    end
  end

  private

  def trigger_post(city_staticid: nil, player_id: nil, airlift: false)
    post "/games/#{game.id}/movement_proposals", params: {
      city_staticid: city_staticid,
      player_id: player_id,
      airlift: airlift
    }.to_json, headers: headers
  end

  def trigger_put(accepted: true)
    put "/games/#{game.id}/movement_proposals/#{movement_proposal.id}",
      params: { accepted: accepted }.to_json, headers: headers
  end
end
