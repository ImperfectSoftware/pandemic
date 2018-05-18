require 'rails_helper'

RSpec.describe GetCardsController, type: :request do
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

  it "returns an error if the other player is not at the same location" do
    player.update!(current_location_staticid: WorldGraph.cities[25].staticid)
    post "/games/#{game.id}/get_cards", params: {
      player_id: player.id
    }.to_json, headers: headers
    expect(error).to eq(I18n.t("get_cards.not_the_same_location"))
  end

  it "returns an error if the other player is not in possession of the card" do
    player.update!(cards_composite_ids: [])
    post "/games/#{game.id}/get_cards", params: {
      player_id: player.id
    }.to_json, headers: headers
    expect(error).to eq(I18n.t("get_cards.not_an_owner"))
  end

  context "with valid request" do
    before(:each) do
      player.update!(
        cards_composite_ids: [player.current_location.composite_id]
      )
    end

    it "stores the current player's id in the to_player_id field" do
      post "/games/#{game.id}/get_cards", params: {
        player_id: player.id
      }.to_json, headers: headers
      expect(ShareKnowledge.last.to_player_id).to eq(current_player.id)
    end

    it "stores the other player's id in the from_player_id field" do
      post "/games/#{game.id}/get_cards", params: {
        player_id: player.id
      }.to_json, headers: headers
      expect(ShareKnowledge.last.from_player_id).to eq(player.id)
    end

    it "sets accepted to false" do
      post "/games/#{game.id}/get_cards", params: {
        player_id: player.id
      }.to_json, headers: headers
      expect(ShareKnowledge.last.accepted).to be(false)
    end

    it "stores the card composite id" do
      post "/games/#{game.id}/get_cards", params: {
        player_id: player.id
      }.to_json, headers: headers
      expect(ShareKnowledge.last.card_composite_id)
        .to eq(player.current_location.composite_id)
    end
  end
end
