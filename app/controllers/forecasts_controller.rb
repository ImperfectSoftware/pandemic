class ForecastsController < ApplicationController
  before_action :check_for_potential_errors

  def index
    forecast_card
  end

  private

  def check_for_potential_errors
    render json: { error: create_error_message }
  end

  def create_error_message
    if current_player.event_cards.find { |card| card.forecast? }.nil?
      I18n.t("player_actions.must_own_card")
    end
  end

  def forecast_card
    current_player.event_cards.find { |card| card.forecast? }
  end

  def game
    @game ||= current_user.games.find_by(id: params[:game_id])
  end

  def current_player
    @current_player ||= current_user.players.find_by(game: game)
  end
end
