class ForecastsController < ApplicationController
  before_action :check_for_potential_errors, only: :create

  def create
    if !forecast_performed_this_turn?
      game.discarded_special_player_card_ids << forecast_card.staticid
      game.save!
      current_player.update!(cards_composite_ids: remaining_cards)
      game.forecasts.create!(turn_nr: game.turn_nr)
    end
    @static_ids = game.unused_infection_card_city_staticids.last(6)
  end

  private

  def check_for_potential_errors
    render json: { error: create_error_message } if create_error_message
  end

  def create_error_message
    if forecast_card.nil? && !forecast_performed_this_turn?
      I18n.t("player_actions.must_own_card")
    end
  end

  def forecast_card
    current_player.events.find { |card| card.forecast? }
  end

  def game
    @game ||= current_user.games.find_by(id: params[:game_id])
  end

  def current_player
    @current_player ||= current_user.players.find_by(game: game)
  end

  def forecast_performed_this_turn?
    game.forecasts.last&.turn_nr == game.turn_nr
  end

  def remaining_cards
    current_player.cards_composite_ids - [forecast_card.composite_id]
  end
end
