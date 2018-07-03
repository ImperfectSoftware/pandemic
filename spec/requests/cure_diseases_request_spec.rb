require 'rails_helper'

RSpec.describe CureDiseasesController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:cities) { WorldGraph.cities[18..22] }
  let(:city_staticids) { cities.map(&:staticid) }
  let(:city_composite_ids) { cities.map(&:composite_id) }

  before(:each) do
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  it "returns an error if the current player is not at the research station" do
    trigger_post
    location = current_player.location
    expect(error)
      .to eq(I18n.t("player_actions.city_with_no_station", name: location.name))
  end

  context "with research station" do
    before(:each) do
      location = current_player.location
      game.research_stations.create!(city_staticid: location.staticid)
      current_player.update!(role: Player.roles.keys[1])
    end

    it "returns error if 4 cards are passed in" do
      city_staticids = WorldGraph.cities[0,4].map(&:staticid)
      trigger_post(city_staticids: city_staticids)
      expect(error).to eq(I18n.t("cure_diseases.wrong_number_of_cards"))
    end

    context "with current player as a scientist" do
      it "does not return error if 4 cards are passed in" do
        current_player.update!(
          role: Player.roles.keys[6],
          cards_composite_ids: city_composite_ids
        )
        trigger_post(city_staticids: city_staticids[1..-1])
        expect(game.cure_markers.find_by(color: 'blue')).to_not be_nil
      end
    end

    it "returns error if less than 5 unique cards are passed in" do
      city_staticids = WorldGraph.cities[0,4].map(&:staticid)
      city_staticids << city_staticids.first
      trigger_post(city_staticids: city_staticids)
      expect(error).to eq(I18n.t("cure_diseases.wrong_number_of_cards"))
    end

    it "returns error if 6 cards are passed in" do
      city_staticids = WorldGraph.cities[0,6].map(&:staticid)
      trigger_post(city_staticids: city_staticids)
      expect(error).to eq(I18n.t("cure_diseases.wrong_number_of_cards"))
    end

    it "returns an error if the cards are not of the same color" do
      trigger_post(city_staticids: WorldGraph.cities[17..21].map(&:staticid))
      expect(error).to eq(I18n.t("cure_diseases.not_the_same_color"))
    end

    it "returns an error if the player doesn't own the cards" do
      current_player.update!(cards_composite_ids: [])
      trigger_post(city_staticids: city_staticids)
      expect(error).to eq(I18n.t("cure_diseases.player_must_own_cards"))
    end


    it "creates a cure marker" do
      current_player.update!(cards_composite_ids: city_composite_ids)
      trigger_post(city_staticids: city_staticids)
      expect(game.cure_markers.find_by(color: 'blue').cured).to be(true)
    end

    it "sets eradicated to true" do
      current_player.update!(cards_composite_ids: city_composite_ids)
      trigger_post(city_staticids: city_staticids)
      expect(game.cure_markers.find_by(color: 'blue').eradicated).to be(true)
    end

    it "it does not set eradicated to true" do
      current_player.update!(cards_composite_ids: city_composite_ids)
      game.infections.create(
        color: 'blue',
        quantity: 2,
        city_staticid: WorldGraph.cities.first.staticid
      )
      trigger_post(city_staticids: city_staticids)
      expect(game.cure_markers.find_by(color: 'blue').eradicated).to be(false)
    end

    it "errors out if the disease is already cured" do
      current_player.update!(cards_composite_ids: city_composite_ids)
      trigger_post(city_staticids: city_staticids)
      current_player.update!(cards_composite_ids: city_composite_ids)
      trigger_post(city_staticids: %w{23 6 7 8 9})
      expect(error).to eq(I18n.t("cure_diseases.already_cured"))
    end

    it "increases actions taken" do
      current_player.update!(cards_composite_ids: city_composite_ids)
      trigger_post(city_staticids: city_staticids)
      expect(game.reload.actions_taken).to eq(1)
    end

    it "removes player cards from player inventory" do
      current_player.update!(cards_composite_ids: city_composite_ids)
      trigger_post(city_staticids: city_staticids)
      expect(current_player.reload.cards_composite_ids).to eq([])
    end
  end

  private

  def trigger_post(city_staticids: {})
    post "/games/#{game.id}/cure_diseases", params: {
      city_staticids: city_staticids
    }.to_json, headers: headers
  end
end
