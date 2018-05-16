require 'rails_helper'

RSpec.describe ShuttleFlightsController, type: :request do
  include AuthHelper
  before(:context) do
    @current_user = Fabricate(:user, password: '12341234')
    @game = Fabricate(:game, owner: @current_user)
    @player = Fabricate(:player, game: @game)
    @user = @player.user
  end

  it "returns error message if it's not the current player's turn" do
    @game.update(turn_nr: 2)
    post "/games/#{@game.id}/shuttle_flights", params: {}, headers: headers
    expect(JSON.parse(response.body)['error'])
      .to eq(I18n.t('player_actions.not_your_turn'))
  end

end
