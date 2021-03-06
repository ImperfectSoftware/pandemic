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
    current_player.update!(role: Player.roles.keys.first)
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  it "returns an error if the other player is not at the same location" do
    player.update!(location_staticid: WorldGraph.cities[25].staticid)
    trigger_post
    expect(error).to eq(I18n.t("share_cards.not_the_same_location"))
  end

  it "returns an error if the other player is not in possession of the card" do
    player.update!(cards_composite_ids: [])
    trigger_post
    expect(error).to eq(I18n.t("share_cards.not_an_owner"))
  end

  context "when other player is not a researcher" do
    before(:each) { player.update!(role: Player.roles.keys.first) }

    it "returns an error when passing in a city staticid" do
      trigger_post(city_staticid: WorldGraph.cities[25].staticid)
      expect(error).to eq(I18n.t("player_actions.not_a_researcher"))
    end

    it "doesn't return an error when passing in the current location" do
      trigger_post(city_staticid: player.location.staticid)
      expect(ShareCard.last.from_player_id).to eq(player.id)
    end
  end

  context "with valid request" do
    it "stores the current player's id in the to_player_id field" do
      trigger_post
      expect(ShareCard.last.to_player_id).to eq(current_player.id)
    end

    it "stores the other player's id in the from_player_id field" do
      trigger_post
      expect(ShareCard.last.from_player_id).to eq(player.id)
    end

    it "sets accepted to false" do
      trigger_post
      expect(ShareCard.last.accepted).to be(false)
    end

    it "stores the card composite id" do
      trigger_post
      expect(ShareCard.last.city_staticid)
        .to eq(player.location.staticid)
    end

    it "stores the card creator id" do
      trigger_post
      expect(ShareCard.last.creator_id).to eq(current_player.id)
    end

    context "other player as a researcher" do
      it "creates a share card with the passed in location" do
        city = WorldGraph.cities[25]
        player.update!(cards_composite_ids: [city.composite_id])
        player.update!(role: Player.roles.keys[3])
        trigger_post(city_staticid: city.staticid)
        expect(ShareCard.last.city_staticid).to eq(city.staticid)
      end
    end

    context "current player as a researcher" do
      it "creates a share card with the passed in location" do
        city = WorldGraph.cities[25]
        player.update!(cards_composite_ids: [city.composite_id])
        current_player.update!(role: Player.roles.keys[3])
        trigger_post(city_staticid: city.staticid)
        expect(ShareCard.last.city_staticid).to eq(city.staticid)
      end
    end

  end

  private

  def trigger_post(city_staticid: nil)
    post "/games/#{game.id}/get_cards", params: {
      player_id: player.id,
      city_staticid: city_staticid
    }.to_json, headers: headers
  end
end
