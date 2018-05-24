require 'rails_helper'

RSpec.describe Games::ForecastsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:forecast_card) { SpecialCard.events.find(&:forecast?) }
  let(:static_ids) { WorldGraph.cities[0, 12].map(&:staticid) }

  it "returns error if the current player does not own the event card" do
    post "/games/#{game.id}/forecasts", headers: headers
    expect(error).to eq(I18n.t("player_actions.must_own_card"))
  end

  it "places the card in the discarded cards pile" do
    current_player.update!(cards_composite_ids: [forecast_card.composite_id])
    post "/games/#{game.id}/forecasts", headers: headers
    expect(game.reload.discarded_events.include?(forecast_card)).to be(true)
  end

  context "with valid request" do
    before(:each) do
      game.update!(unused_infection_card_city_staticids: static_ids)
      current_player.update!(cards_composite_ids: [forecast_card.composite_id])
    end

    context "and with forecast request triggered on the same turn" do
      it "responds with the last 6" do
        post "/games/#{game.id}/forecasts", headers: headers
        post "/games/#{game.id}/forecasts", headers: headers
        expect(body['city_staticids']).to eq(static_ids[6, 6])
      end
    end

    it "responds with the last 6 cards from the infection deck" do
      post "/games/#{game.id}/forecasts", headers: headers
      expect(body['city_staticids']).to eq(static_ids[6, 6])
    end

    it "removes the forecast card from the player's invetory" do
      post "/games/#{game.id}/forecasts", headers: headers
      expect(body['city_staticids']).to eq(static_ids[6, 6])
      expect(current_player.reload.cards_composite_ids).to eq([])
    end
  end
end
