require 'rails_helper'

RSpec.describe Games::ResilientPopulationsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:game) { Fabricate(:game) }
  let(:current_user) { game.owner }
  let(:resilient_population) { SpecialCard.resilient_population }

  context "GET request" do
    it "returns a list of infection cards" do
      game.update!(
        unused_infection_card_city_staticids: (1..20).map(&:to_s),
        nr_of_intensified_cards: 5
      )
      trigger_get
      expect(body['cities'].count).to eq(5)
    end
  end

  context "DELETE request" do
    before(:each) do
      game.update!(
        nr_of_intensified_cards: 3,
        unused_infection_card_city_staticids: %w{7 8 9}
      )
    end

    it "returns error message if no city_staticid provided" do
      trigger_delete
      expect(error).to eq(I18n.t("player_actions.city_staticid"))
    end

    it "returns error if current_player does not own the resilient card" do
      trigger_delete(city_staticid: '7')
      expect(error).to eq(I18n.t("errors.not_authorized"))
    end

    context "when player is in possession of the resilient population card" do
      let(:player) { game.players.first }
      before(:each) do
        player
          .update!(cards_composite_ids: [resilient_population.composite_id])
      end

      it "returns error message if city is not part of the used cards" do
        trigger_delete(city_staticid: '35')
        expect(error).to eq(I18n.t("errors.not_authorized"))
      end

      it "removes infection card from infection card pile" do
        trigger_delete(city_staticid: '8')
        expect(game.reload.unused_infection_card_city_staticids)
          .to eq(%w{7 9})
      end

      it "removes special card from player's inventory" do
        trigger_delete(city_staticid: '7')
        expect(player.reload.owns_card?(resilient_population)).to be(false)
      end

      it "places card in discarded special cards" do
        trigger_delete(city_staticid: '7')
        discarded_cards = game.reload.discarded_special_player_card_ids
        expect(discarded_cards.include?(resilient_population.staticid))
          .to be(true)
      end
    end
  end

  private

  def trigger_get
    get "/games/#{game.id}/resilient_populations.json", headers: headers
  end

  def trigger_delete(city_staticid: nil)
    delete "/games/#{game.id}/resilient_populations", params: {
      city_staticid: city_staticid
    }.to_json, headers: headers
  end
end
