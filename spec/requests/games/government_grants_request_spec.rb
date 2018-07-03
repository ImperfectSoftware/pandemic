require 'rails_helper'

RSpec.describe Games::GovernmentGrantsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:two_player_game, owner: current_user) }
  let(:player_one) { game.players.first }
  let(:player_two) { game.players.last }
  let(:city) { WorldGraph.cities[0] }
  let(:station) { game.research_stations.find_by(city_staticid: city.staticid) }
  let(:government_grant) { SpecialCard.events.find(&:government_grant?) }

  context "when a player owns the government grant card" do
    before(:each) do
      player_one.update(cards_composite_ids: [government_grant.composite_id])
      player_two.update(cards_composite_ids: [government_grant.composite_id])
    end

    it "creates a research center when it is the player's turn" do
      trigger_post
      expect(station).to_not be_nil
    end

    it "creates a research center when not the player's turn" do
      game.update!(turn_nr: 2)
      trigger_post
      expect(station).to_not be_nil
      expect(game.reload.actions_taken).to eq(0)
    end

    it "discards of the government grant card" do
      trigger_post
      expect(player_one.reload.cards_composite_ids).to eq([])
    end

    it "adds event card to discarded pile" do
      trigger_post
      expect(game.reload.discarded_special_player_card_ids.count).to eq(1)
    end

    context "when all research stations used" do
      it "doesn't create a research station" do
        WorldGraph.cities[10,6].each do |city|
          game.research_stations.create!(city_staticid: city.staticid)
        end
        trigger_post
        expect(error).to eq(I18n.t('research_stations.none_left'))
      end
    end

    context "when a research station already exists" do
      it "doesn't create a research station" do
        game.research_stations.create!(city_staticid: city.staticid)
        change_logged_in_user(current_user)
        trigger_post
        expect(error).to eq(I18n.t("government_grant.alread_exists"))
      end
    end
  end

  context "withouth a government grant card" do
    it "doesn't create a research station" do
      trigger_post
      expect(error).to eq(I18n.t("player_actions.must_own_card"))
    end
  end

  it "raises an error if no city staticid was provided" do
    player_one.update(cards_composite_ids: [government_grant.composite_id])
    trigger_post(city_staticid: nil)
    expect(error).to eq(I18n.t("player_actions.city_staticid"))
  end

  def trigger_post(city_staticid: city.staticid)
    post "/games/#{game.id}/government_grant", params: {
      city_staticid: city_staticid
    }.to_json, headers: headers
  end
end
