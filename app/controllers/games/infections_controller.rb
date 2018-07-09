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
      game.discard_event!(event)
      current_player.cards_composite_ids.delete(event.composite_id)
      current_player.save!
    end
  end

  def event
    current_player.events.find(&:forecast?)
  end
end
