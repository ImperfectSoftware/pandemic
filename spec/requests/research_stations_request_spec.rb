require 'rails_helper'

RSpec.describe ResearchStationsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:user) { user.players.find_by(game: game) }

  before(:each) do
    # We must assign a role other than Operations Expert.
    current_player.update!(role: Role.all[1,5].sample.name)
    game.update(player_turn_ids: [current_player.id, player.id])
  end

  it "returns no reserach stations left to be placed error" do
    6.times { Fabricate(:research_station, game: game) }
    trigger_valid_post
    expect(error).to eq(I18n.t('research_stations.none_left'))
  end

  it "returns error if the player doesn't own the current location" do
    current_player.update!(cards_composite_ids: [])
    trigger_valid_post
    expect(error).to eq(I18n.t('player_actions.must_own_card'))
  end

  it "creates a research station at the current location" do
    trigger_valid_post
    expect(body['city_staticid'])
      .to eq(current_player.location.staticid)
  end

  it "increments actions taken" do
    trigger_valid_post
    expect(game.reload.actions_taken).to eq(1)
  end

  it "removes card from player's inventory" do
    composite_id = current_player.location.composite_id
    trigger_valid_post
    expect(current_player.reload.cards_composite_ids.include?(composite_id))
      .to be(false)
  end


  context "when player is an operations expert" do
    before(:each) do
      current_player.update!(role: Role.all.first.name)
    end

    it "doesn't return must own card error if player is an operations expert" do
      current_player.update!(cards_composite_ids: [])
      trigger_valid_post
      expect(error).to be_nil
    end

    it "doesn't remove cards from the current player's inventory" do
      composite_id = current_player.location.composite_id
      current_player.update!(cards_composite_ids: [composite_id])
      trigger_valid_post
      expect(current_player.reload.cards_composite_ids.include?(composite_id))
        .to be(true)
    end
  end

  private

  def trigger_valid_post
    post "/games/#{game.id}/research_stations", params: {}, headers: headers
  end
end
