require 'rails_helper'

RSpec.describe Games::SpecialCardsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:game) { Fabricate(:game) }
  let(:current_user) { game.owner }
  let(:current_player) { game.players.first }
  let(:player) { Fabricate(:player, game: game) }
  let(:special_card) { SpecialCard.events.first }

  context "GET action" do
    it "returns an error if current_player is not the active player" do
      game.update!(player_turn_ids: [player.id, current_player.id])
      trigger_get
      expect(error).to eq(I18n.t("player_actions.bad_turn"))
    end

    it "returns an error if the player is not the contingency player" do
      game.update!(player_turn_ids: [current_player.id, player.id])
      current_player.update!(role: Player.roles.keys.first)
      trigger_get
      expect(error).to eq(I18n.t("special_cards.bad_role"))
    end

    it "returns a list of non duplicated discarded special cards" do
      game.update!(
        player_turn_ids: [current_player.id, player.id],
        discarded_special_player_card_ids: %w{4 1 2 4 5 3 5}
      )
      current_player.update!(role: Player.roles.keys.second)
      trigger_get
      expect(body['staticids']).to eq(%w{1 2 3})
    end
  end

  context "POST action"do
    it "returns error if current player is not the contingency planner" do
      game.update!(player_turn_ids: [current_player.id, player.id])
      current_player.update!(role: Player.roles.keys.first)
      trigger_post
      expect(error).to eq(I18n.t("special_cards.bad_role"))
    end

    describe "trying to extract a card that has not been discarded yet" do
      it "returns an error" do
        game.update!(player_turn_ids: [current_player.id, player.id])
        current_player.update!(role: Player.roles.keys.second)
        trigger_post
        expect(error).to eq(I18n.t("errors.not_authorized"))
      end
    end

    context "with valid request" do
      before(:each) do
        game.update!(
          discarded_special_player_card_ids: %w{4 1 2 4 5 3 5},
          player_turn_ids: [current_player.id, player.id])
        current_player.update!(role: Player.roles.keys.second)
        trigger_post
      end

      it "increases actions taken by 1" do
        expect(game.reload.actions_taken).to eq(1)
      end

      it "places the special card in the player's inventory" do
        composite_ids = current_player.reload.cards_composite_ids
        expect(composite_ids.include?(special_card.composite_id)).to be(true)
      end
    end
  end

  private

  def trigger_get
    get "/games/#{game.id}/special_cards", params: {}, headers: headers
  end

  def trigger_post
    post "/games/#{game.id}/special_cards", params: {
      special_card_staticid: special_card.staticid
    }.to_json, headers: headers
  end
end
