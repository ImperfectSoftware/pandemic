class Games::ResilientPopulationsController < ApplicationController
  before_action :check_for_authorization, only: [:show, :create]
  before_action :check_for_potential_create_errors, only: :create

  def show
  end

  def create
    game.unused_infection_card_city_staticids.pop
    game.discarded_special_player_card_ids << card.staticid
    game.save!
    current_player.update!(cards_composite_ids: remaining_cards)
  end

  private

  def check_for_authorization
    if !game.between_epidemic_stages?
      render json: { error: I18n.t("errors.not_authorized") }
    end
  end

  def check_for_potential_create_errors
    render json: { error: create_error_message } if create_error_message
  end

  def create_error_message
    @create_error_message ||=
      begin
        case
        when params[:city_staticid].blank?
          I18n.t("player_actions.city_staticid")
        when !current_player.owns_card?(card)
          I18n.t("errors.not_authorized")
        when !game.used_cards.map(&:staticid).include?(params[:city_staticid])
          I18n.t("errors.not_authorized")
        end
      end
  end

  def remaining_cards
    current_player.cards_composite_ids - [card.composite_id]
  end

  def card
    SpecialCard.resilient_population
  end
end
