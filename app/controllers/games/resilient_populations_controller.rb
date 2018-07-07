class Games::ResilientPopulationsController < ApplicationController
  include GameBroadcast
  before_action :check_for_potential_delete_errors, only: :destroy

  helper_method :cities

  def show
  end

  def destroy
    game.used_infection_card_city_staticids.delete(params[:city_staticid])
    game.unused_infection_card_city_staticids.delete(params[:city_staticid])
    game.discarded_special_player_card_ids << card.staticid
    game.save!
    current_player.update!(cards_composite_ids: remaining_cards)
    send_game_broadcast
  end

  private

  def check_for_potential_delete_errors
    render json: { error: delete_error_message } if delete_error_message
  end


  def delete_error_message
    @delete_error_message ||=
      begin
        case
        when params[:city_staticid].blank?
          I18n.t("player_actions.city_staticid")
        when !current_player.owns_card?(card)
          I18n.t("errors.not_authorized")
        when city_is_not_removable?
          I18n.t("errors.not_authorized")
        end
      end
  end

  def city_is_not_removable?
    !game.resilient_population_cards.map(&:staticid)
      .include?(params[:city_staticid])
  end

  def remaining_cards
    current_player.cards_composite_ids - [card.composite_id]
  end

  def card
    SpecialCard.resilient_population
  end

  def cities
    @cities ||= game.resilient_population_cards
  end
end
