require 'rails_helper'

RSpec.describe Games::InfectionsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:game) { Fabricate(:game) }
  let(:current_user) { game.owner }
  let(:current_player) { game.players.first }
  let(:player) { Fabricate(:player, game: game) }

  it "errors out if current player is not the active player" do
    game.update!(turn_nr: 2, player_turn_ids: [current_player.id, player.id])
    trigger_post
    expect(error).to eq(I18n.t('player_actions.bad_turn'))
  end

  it "errors out if two player cards have not been drawn yet" do
    game.update!(player_turn_ids: [current_player.id, player.id])
    trigger_post
    expect(error).to eq(I18n.t("player_actions.draw_cards"))
  end

  it "resets number of intensified cards" do
    game.update!(
      player_turn_ids: [current_player.id, player.id],
      unused_infection_card_city_staticids: %w{1 2 3},
      nr_of_intensified_cards: 4,
      flipped_cards_nr: 2
    )
    trigger_post
    expect(game.reload.nr_of_intensified_cards).to eq(0)
  end

  private

  def trigger_post
    post "/games/#{game.id}/infections", params: {}, headers: headers
  end
end
