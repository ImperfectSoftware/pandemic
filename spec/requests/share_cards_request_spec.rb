require 'rails_helper'

RSpec.describe ShareCardsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:player) { Fabricate(:player, game: game) }
  let(:another_player) { Fabricate(:player, game: game) }
  let(:user) { user.players.find_by(game: game) }
  let(:city) { WorldGraph.cities.first }
  let(:bad_city) { WorldGraph.cities.last }
  let(:card) do
    Fabricate(
      :share_card,
      creator: player,
      from_player: current_player,
      to_player: player,
      city_staticid: city.staticid
    )
  end

  before(:each) do
    game.update(player_turn_ids: [
      current_player.id,
      player.id,
      another_player.id
    ])
  end

  it "does nothing if accepted is set to false" do
    trigger_put(accepted: false)
    expect(body['accepted']).to be(false)
  end

  it "returns error if active player has no actions left" do
    game.update!(actions_taken: 4)
    trigger_put
    expect(error).to eq(I18n.t('player_actions.no_actions_left'))
  end

  it "returns error if it's not the from or to player's turn" do
    game.update!(turn_nr: 3)
    trigger_put
    expect(error).to eq(I18n.t('player_actions.bad_turn'))
  end

  it "returns error if the from player is no longer at the card's location" do
    player.update(location_staticid: city.staticid)
    current_player.update(location_staticid: bad_city.staticid)
    trigger_put
    expect(error).to eq(I18n.t('share_cards.from_player_bad_location'))
  end

  it "returns error if the to player is no longer at the card's location" do
    player.update(location_staticid: bad_city.staticid)
    current_player.update(location_staticid: city.staticid)
    trigger_put
    expect(error).to eq(I18n.t('share_cards.to_player_bad_location'))
  end

  it "returns error if the current player is the share card creator" do
    card.update!(creator: current_player)
    trigger_put
    expect(error).to eq(I18n.t('share_cards.not_authorized'))
  end

  it "accepts the card" do
    trigger_put
    expect(body['accepted']).to be(true)
  end

  it "increments actions takens" do
    trigger_put
    expect(game.reload.actions_taken).to eq(1)
  end

  it "returns error if the from player is no longer the owner of the card" do
    current_player.update!(
      location_staticid: city.staticid,
      cards_composite_ids: []
    )
    player.update(location_staticid: city.staticid)
    trigger_put
    expect(error).to eq(I18n.t('share_cards.not_an_owner'))
  end

  it "remove card from the from player's possession" do
    trigger_put
    expect(current_player.reload.owns_card?(card.location)).to be(false)
  end

  it "places the card in the to player's possession" do
    player.update!(cards_composite_ids: [])
    trigger_put
    expect(player.reload.owns_card?(card.location)).to be(true)
  end

  private

  def trigger_put(accepted: true)
    put "/games/#{game.id}/share_cards/#{card.id}", params: {
      accepted: accepted
    }.to_json, headers: headers
  end

end
