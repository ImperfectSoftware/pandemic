require 'rails_helper'

RSpec.describe PlayerActionsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  before(:context) do
    @current_user = Fabricate(:user, password: '12341234')
    @game = Fabricate(:game, owner: @current_user)
    @current_player = @current_user.players.find_by(game: @game)
    @player = Fabricate(:player, game: @game)
    @user = @player.user
    @game.update(player_turn_ids: [@current_player.id, @player.id])
  end

  it "returns error message if it's not the current player's turn" do
    @game.update(turn_nr: 2)
    post "/games/#{@game.id}/shuttle_flights", params: {}, headers: headers
    expect(error).to eq(I18n.t('player_actions.bad_turn'))
  end

  it "returns error message if the player has no actions left" do
    @game.update(actions_taken: 4)
    post "/games/#{@game.id}/shuttle_flights", params: {}, headers: headers
    expect(error).to eq(I18n.t('player_actions.no_actions_left'))
  end

  it 'returns error message if any player has more than 7 city cards' do
    @current_player.update(cards_composite_ids: WorldGraph.composite_ids[0,8])
    post "/games/#{@game.id}/shuttle_flights", params: {}, headers: headers
    expect(error).to eq(I18n.t('player_actions.discard_player_city_card'))
  end
end
