require 'rails_helper'

RSpec.describe CureDiseasesController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }

  before(:each) do
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  it "returns an error if the current player is not at the research station" do
    trigger_post
    location = current_player.location
    expect(error)
      .to eq(I18n.t("player_actions.city_with_no_station", name: location.name))
  end

  context "with wrong number of cards passed in" do
    before(:each) do
      location = current_player.location
      game.research_stations.create!(city_staticid: location.staticid)
    end

    it "returns error if 4 cards are passed in" do
      city_staticids = WorldGraph.cities[0,4].map(&:staticid)
      trigger_post(city_staticids: city_staticids)
      expect(error).to eq(I18n.t("cure_diseases.five_cards_must_be_provided"))
    end

    it "returns error if less than 5 unique cards are passed in" do
      city_staticids = WorldGraph.cities[0,4].map(&:staticid)
      city_staticids << city_staticids.first
      trigger_post(city_staticids: city_staticids)
      expect(error).to eq(I18n.t("cure_diseases.five_cards_must_be_provided"))
    end

    it "returns error if 6 cards are passed in" do
      city_staticids = WorldGraph.cities[0,6].map(&:staticid)
      trigger_post(city_staticids: city_staticids)
      expect(error).to eq(I18n.t("cure_diseases.five_cards_must_be_provided"))
    end
  end

  private

  def trigger_post(city_staticids: {})
    post "/games/#{game.id}/cure_diseases", params: {
      city_staticids: city_staticids
    }.to_json, headers: headers
  end
end
