require 'rails_helper'

RSpec.describe Games::FlipCardsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:game) { Fabricate(:game) }
  let(:current_user) { game.owner }
  let(:current_player) { game.players.first }
  let(:player) { Fabricate(:player, game: game) }

  before(:each) do
    game.update!(player_turn_ids: [current_player.id, player.id])
  end

  it "returns an error if it's not the current player's turn" do
    game.update!(turn_nr: 2)
    trigger_post
    expect(error).to eq(I18n.t('player_actions.bad_turn'))
  end

  it "returns an error if no flip cards left" do
    game.update!(flipped_cards_nr: 2)
    trigger_post
    expect(error).to eq(I18n.t("player_actions.flipped_max"))
  end

  it "triggers a flip card event and ends the game" do
    trigger_post
    expect(game.reload.finished?).to be(true)
  end

  private

  def trigger_post
    post "/games/#{game.id}/flip_cards", params: {}, headers: headers
  end
end
