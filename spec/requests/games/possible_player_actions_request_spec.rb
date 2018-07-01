require 'rails_helper'

RSpec.describe Games::PossiblePlayerActionsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:player) { game.players.first }

  context "operations expert" do
    before(:each) do
      player.operations_expert!
    end

    it "should display cities if at research station" do
      game.research_stations.create!(city_staticid: player.location.staticid)
      trigger_get
      expect(body['operations_expert_locations'].count).to eq(47)
    end

    describe "when the action was already taken" do
      it "should display cities if at research station" do
        game.research_stations.create!(city_staticid: player.location.staticid)
        player.operations_expert_actions.create!(turn_nr: game.turn_nr)
        trigger_get
        expect(body['operations_expert_locations'].count).to eq(0)
      end
    end

    it "should display no cities if NOT at research station" do
      trigger_get
      expect(body['operations_expert_locations'].count).to eq(0)
    end
  end

  private

  def trigger_get
    get "/games/#{game.id}/possible_player_actions",
      params: { city_staticid: '5', player_id: player.id }, headers: headers
  end
end
