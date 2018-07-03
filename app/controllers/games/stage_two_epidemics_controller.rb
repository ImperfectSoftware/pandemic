class Games::StageTwoEpidemicsController < ApplicationController
  include GamesBroadcast
  before_action :check_for_potential_create_errors, only: :create

  def create
    StageTwoEpidemic.new(game: game).call
    # TODO: refactor here and finish turns controller
    if game.flipped_cards_nr == 2
      game.update!(actions_taken: 0, flipped_cards_nr: 0)
      game.increment!(:turn_nr)
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
        when !game.between_epidemic_stages?
          I18n.t("errors.not_authorized")
        end
      end
  end
end
