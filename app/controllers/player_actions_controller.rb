class PlayerActionsController < ApplicationController
  before_action :ensure_player_can_act, only: :create
  before_action :check_for_potential_create_errors, only: :create

  private

  def current_player
    @current_player ||= current_user.players.find_by(game: game)
  end

  def game
    @game ||= current_user.games.find_by(id: params[:game_id])
  end

  def active_player_id
    GetActivePlayer.new(
      player_ids: game.player_turn_ids,
      turn_nr: game.turn_nr
    ).call.result
  end

  def active_player
    @active_player ||= game.players.find_by(id: active_player_id)
  end

  def ensure_player_can_act
    render json: { error: error_message } if error_message
  end

  def check_for_potential_create_errors
    render json: { error: create_error_message } if create_error_message
  end

  def error_message
    @error_message ||=
      begin
        if current_player != active_player
          I18n.t('player_actions.bad_turn')
        elsif game.no_actions_left?
          I18n.t('player_actions.no_actions_left')
        elsif current_player.has_too_many_cards?
          I18n.t('player_actions.discard_player_city_card')
        end
      end
  end

  def create_error_message
    # implement method in subclass
    raise NotImplementedError
  end
end
