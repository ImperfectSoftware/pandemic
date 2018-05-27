class Games::StageTwoEpidemicsController < ApplicationController
  before_action :check_for_potential_create_errors, only: :create

  def create
    StageTwoEpidemic.new(game: game).call
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
