require 'rails_helper'

RSpec.describe Games::PossibleActionsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }

  context "displays attributes" do
    before(:each) do
      trigger_get
    end

    it "displays can drive" do
      expect(body["can_drive"]).to eq(false)
    end

    it "displays can can direct flight" do
      expect(body["can_direct_flight"]).to eq(true)
    end

    it "displays can charter flight" do
      expect(body["can_charter_flight"]).to eq(true)
    end

    it "displays can shuttle flight" do
      expect(body["can_shuttle_flight"]).to eq(false)
    end

    it "displays can place research station" do
      expect(body["can_build_research_station"]).to eq(false)
    end

    it "displays can discover cure" do
      expect(body["can_discover_cure"]).to eq(false)
    end

    it "displays cure color" do
      expect(body["cure_color"]).to eq('none')
    end

    it "can treat blue should be false" do
      expect(body["can_treat_blue"]).to eq(false)
    end

    it "can treat black should be false" do
      expect(body["can_treat_black"]).to eq(false)
    end

    it "can treat red should be false" do
      expect(body["can_treat_red"]).to eq(false)
    end

    it "can treat yellow should be false" do
      expect(body["can_treat_yellow"]).to eq(false)
    end
  end

  context "remove research station" do
    it "can remove research station" do
      WorldGraph.cities[0, 6].each do |city|
        game.research_stations.create!(city_staticid: city.staticid)
      end
      trigger_get
      expect(body["can_remove_research_station"]).to eq(true)
    end

    it "cannot remove research station that doesn't exist" do
      WorldGraph.cities[6, 6].each do |city|
        game.research_stations.create!(city_staticid: city.staticid)
      end
      trigger_get
      expect(body["can_remove_research_station"]).to eq(false)
    end

    it "cannot remove station when less than 6 stations placed" do
      WorldGraph.cities[0, 5].each do |city|
        game.research_stations.create!(city_staticid: city.staticid)
      end
      trigger_get
      expect(body["can_remove_research_station"]).to eq(false)
    end
  end

  private

  def trigger_get
    get "/games/#{game.id}/possible_actions.json",
      params: { city_staticid: '5' }, headers: headers
  end
end
