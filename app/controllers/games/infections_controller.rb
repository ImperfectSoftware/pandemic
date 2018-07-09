class Games::InfectionsController < ApplicationController
  include GameBroadcast
  before_action :check_for_potential_create_errors, only: :create

  def create
    handle_forecast_card
    if game.skip_infections
      game.update!(skip_infections: false)
    else
      Infections.call(game: game)
    end
    send_game_broadcast
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        case
        when current_player != active_player
          I18n.t('player_actions.bad_turn')
        when game.flipped_cards_nr < 2
          I18n.t("player_actions.draw_cards")
        end
      end
  end

  def handle_forecast_card
    if game.forecasts.find_by(turn_nr: game.turn_nr)
      game.discarded_special_player_card_ids << forecast_card.staticid
      game.save!
      current_player.update!(cards_composite_ids: remaining_cards)
    end
  end

  def remaining_cards
    current_player.cards_composite_ids - [forecast_card.composite_id]
  end

  def forecast_card
    current_player.events.find(&:forecast?)
  end
end
