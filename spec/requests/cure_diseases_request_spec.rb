require 'rails_helper'

RSpec.describe CureDiseasesController, type: :request do
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

  it "returns an error if the current player is not at the research station" do
    city = WorldGraph.cities.second
    game.research_stations.create!(city_staticid: city.staticid)
    post "/games/#{game.id}/cure_diseases", params: {}.to_json, headers: headers
    location = current_player.current_location
    expect(error)
      .to eq(I18n.t("player_actions.city_with_no_station", name: location.name))
  end
end
