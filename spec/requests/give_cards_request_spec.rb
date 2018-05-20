require 'rails_helper'

RSpec.describe GiveCardsController, type: :request do
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
    player.update!(location_staticid: WorldGraph.cities[25].staticid)
    trigger_post
    expect(error).to eq(I18n.t("share_cards.not_the_same_location"))
  end

  it "returns an error if the other player is not in possession of the card" do
    current_player.update!(cards_composite_ids: [])
    trigger_post
    expect(error).to eq(I18n.t("share_cards.not_an_owner"))
  end

  context "with valid request" do
    it "stores the current player's id in the from_player_id field" do
      trigger_post
      expect(ShareCard.last.from_player_id).to eq(current_player.id)
    end

    it "stores the other player's id in the to_player_id field" do
      trigger_post
      expect(ShareCard.last.to_player_id).to eq(player.id)
    end

    it "sets accepted to false" do
      trigger_post
      expect(ShareCard.last.accepted).to be(false)
    end

    it "stores the card composite id" do
      trigger_post
      expect(ShareCard.last.city_staticid) .to eq(player.location.staticid)
    end

    it "stores the card creator id" do
      trigger_post
      expect(ShareCard.last.creator_id).to eq(current_player.id)
    end
  end

  private

  def trigger_post
    post "/games/#{game.id}/give_cards", params: {
      player_id: player.id
    }.to_json, headers: headers
  end
end
