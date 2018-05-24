require 'rails_helper'

RSpec.describe Games::DiscardCityCardsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:city) { WorldGraph.cities[10] }
  let(:city2) { WorldGraph.cities[11] }

  it "removes card from player's inventory" do
    composite_ids = [city.composite_id, city2.composite_id]
    current_player.update!(cards_composite_ids: composite_ids)
    trigger_delete(city_staticid: city.staticid)
    expect(current_player.reload.cards_composite_ids)
      .to eq([city2.composite_id])
  end

  it "does nothing if the player is no longer in the possesion of the card" do
    current_player.update!(cards_composite_ids: [])
    trigger_delete
    expect(response.status).to be(204)
  end

  private

  def trigger_delete(city_staticid: nil)
    delete "/games/#{game.id}/discard_city_cards", params: {
      city_staticid: city_staticid
    }.to_json, headers: headers
  end
end
