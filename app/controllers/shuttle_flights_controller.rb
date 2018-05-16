class ShuttleFlightsController < ApplicationController
  def create
    if current_player != active_player
      render json: { error: I18n.t('player_actions.not_your_turn') }
    end
  end

  private

  def current_player
    @current_player ||= current_user.players.find_by(game: game)
  end

  def active_player
    @active_player ||= game.players.find_by(id: active_player_id)
  end

  def game
    @game ||= current_user.games.find_by(id: params[:game_id])
  end

  def active_player_id
    GetActivePlayer.new(
      player_ids: game.players.pluck(:id),
      turn_nr: game.turn_nr
    ).call.result
  end

end
