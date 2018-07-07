require 'rails_helper'

RSpec.describe Games::ForecastsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:forecast_card) { SpecialCard.events.find(&:forecast?) }
  let(:static_ids) { WorldGraph.cities[0, 12].map(&:staticid) }

  context "when creating a forecast" do
    it "returns error if the current player does not own the event card" do
      trigger_post
      expect(error).to eq(I18n.t("player_actions.must_own_card"))
    end

    context "with valid request" do
      before(:each) do
        game.update!(unused_infection_card_city_staticids: static_ids)
        current_player.update!(cards_composite_ids: [forecast_card.composite_id])
      end

      it "responds with the last 6 cards from the infection deck" do
        trigger_post
        expect(body['cities'].count).to eq(6)
      end
    end
  end

  context "when updating a forecast" do
    let(:unused_staticids) { WorldGraph.cities.sample(20).map(&:staticid) }
    it "returns an error if last forecast is not in the same game turn" do
      game.update!(turn_nr: 4)
      trigger_put
      expect(error).to eq(I18n.t("errors.not_authorized"))
    end

    it "returns an error when incorrect static ids are sent as params" do
      current_player.update!(cards_composite_ids: [forecast_card.composite_id])
      game.update!(unused_infection_card_city_staticids: unused_staticids)
      trigger_post
      trigger_put(staticids: unused_staticids[10, 6])
      expect(error).to eq(I18n.t("forecasts.bad_staticids"))
    end

    it "updates the last 6 cards provided in the correct order" do
      current_player.update!(cards_composite_ids: [forecast_card.composite_id])
      game.update!(unused_infection_card_city_staticids: unused_staticids)
      trigger_post
      trigger_put(staticids: unused_staticids[14, 6].reverse)
      expect(game.reload.unused_infection_card_city_staticids.last(6))
        .to eq(unused_staticids[14, 6].reverse)
    end
  end

  private

  def trigger_post
    post "/games/#{game.id}/forecasts", headers: headers
  end

  def trigger_put(staticids: [])
    put "/games/#{game.id}/forecasts", params: {
      city_staticids: staticids
    }.to_json, headers: headers
  end
end
