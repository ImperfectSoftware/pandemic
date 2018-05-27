require 'rails_helper'

RSpec.describe Games::ResilientPopulationsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:game) { Fabricate(:game) }
  let(:current_user) { game.owner }

  context "GET request" do
    it "returns error message if not between epidemic stages" do
      trigger_get
      expect(error).to eq(I18n.t("errors.not_authorized"))
    end

    it "returns a list of staticids representing used infection cards" do
      game.update!(
        unused_infection_card_city_staticids: (1..20).map(&:to_s),
        nr_of_intensified_cards: 5
      )
      trigger_get
      expect(body['staticids'].sort).to eq(%w{16 17 18 19 20})
    end
  end

  private

  def trigger_get
    get "/games/#{game.id}/resilient_populations.json", headers: headers
  end
end
