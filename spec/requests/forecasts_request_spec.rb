require 'rails_helper'

RSpec.describe ForecastsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:current_user) { Fabricate(:user, password: '12341234') }
  let(:game) { Fabricate(:game, owner: current_user) }
  let(:current_player) { current_user.players.find_by(game: game) }
  let(:forecast_card) { SpecialCard.events.find(&:forecast?) }

  it "returns error if the current player does not own the event card" do
    get "/games/#{game.id}/forecasts", headers: headers
    expect(error).to eq(I18n.t("player_actions.must_own_card"))
  end

  it "place card in discarded cards pile" do
    current_player.update!(cards_composite_ids: [forecast_card.composite_id])
    get "/games/#{game.id}/forecasts", headers: headers
    expect(game
      .discarded_special_player_card_ids
      .include?(forecast_card.composite_id))
      .to_be true
  end
end
