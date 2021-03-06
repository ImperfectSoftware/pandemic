class PlayerActionsController < ApplicationController
  include GameBroadcast

  before_action :ensure_player_can_act, only: :create
  before_action :check_for_potential_create_errors, only: :create

  private

  def ensure_player_can_act
    render json: { error: error_message } if error_message
  end

  def error_message
    @error_message ||=
      begin
        if current_player != active_player
          I18n.t('player_actions.bad_turn')
        elsif game.no_actions_left?
          I18n.t('player_actions.no_actions_left')
        elsif game.player_with_too_many_cards
          I18n.t(
            'player_actions.discard_player_card',
            username: game.player_with_too_many_cards.user.username
          )
        end
      end
  end

  def create_error_message
    # implement method in subclass
    raise NotImplementedError
  end
end
