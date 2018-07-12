require 'rails_helper'

RSpec.describe Games::InfectionsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  let(:game) { Fabricate(:game) }
  let(:current_user) { game.owner }
  let(:current_player) { game.players.first }
  let(:player) { Fabricate(:player, game: game) }
  let(:forecast_card) { SpecialCard.events.find(&:forecast?) }

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

  context "using quiet night" do
    before(:each) do
      game.update!(
        player_turn_ids: [current_player.id, player.id],
        unused_infection_card_city_staticids: %w{1 2 3},
        nr_of_intensified_cards: 4,
        flipped_cards_nr: 2,
        skip_infections: true,
        actions_taken: 4
      )
    end

    it "skips infections if using quiet night event card" do
      expect { trigger_post }.to change { Infection.total_quantity }.by(0)
      expect(game.reload.skip_infections).to eq(false)
    end

    it "resets nr of intensified cards" do
      trigger_post
      expect(game.reload.nr_of_intensified_cards).to eq(0)
    end

    it "resets nr of flipped cards" do
      trigger_post
      expect(game.reload.flipped_cards_nr).to eq(0)
    end

    it "resets actions taken" do
      trigger_post
      expect(game.reload.actions_taken).to eq(0)
    end

    it "increases the turn nr" do
      turn_nr = game.turn_nr
      trigger_post
      expect(game.reload.turn_nr - turn_nr).to eq(1)
    end
  end

  context "when forecast event card used" do
    before(:each) do
      game.update!(
        player_turn_ids: [current_player.id, player.id],
        unused_infection_card_city_staticids: %w{1 2 3},
        flipped_cards_nr: 2
      )
      current_player.update!(cards_composite_ids: [forecast_card.composite_id])
      game.forecasts.create!(turn_nr: game.turn_nr)
      trigger_post
    end

    it "discards card from player inventory" do
      expect(current_player.reload.cards_composite_ids).to eq([])
    end

    it "places card in discarded special player cards" do
      expect(game.reload.discarded_special_player_card_ids.last)
        .to eq(forecast_card.staticid)
    end
  end

  private

  def trigger_post
    post "/games/#{game.id}/infections", params: {}, headers: headers
  end
end
