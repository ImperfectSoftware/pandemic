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
    staticid = WorldGraph.cities.second.staticid
    game.research_stations.create!(city_staticid: staticid)
    post "/games/#{game.id}/cure_diseases", params: {
      cards_composite_ids: current_player.cards_composite_ids
    }.to_json, headers: headers
    expect(error).to eq(I18n.t("cure_diseases.player_must_be_at_research_station"))
  end
end
