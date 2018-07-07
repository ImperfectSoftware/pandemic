require 'rails_helper'

RSpec.describe Games::PossiblePlayerActionsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:player) { game.players.first }

  private

  def trigger_post
    post "/games/#{game.id}/airlifts", params: {
      city_staticid: city_staticid,
      player_id: player_id
    }.to_json, headers: headers
  end
end
