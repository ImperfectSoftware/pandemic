require 'rails_helper'

RSpec.describe Games::PossiblePlayerActionsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:player) { game.players.first }

  private

  def trigger_get
    get "/games/#{game.id}/possible_player_actions",
      params: { city_staticid: '5', player_id: player.id }, headers: headers
  end
end
