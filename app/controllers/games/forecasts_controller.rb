class Games::ForecastsController < ApplicationController
  before_action :check_for_potential_create_errors, only: :create
  before_action :check_for_potential_update_errors, only: :update

  def create
    if !forecast_performed_this_turn?
      game.discarded_special_player_card_ids << forecast_card.staticid
      game.save!
      current_player.update!(cards_composite_ids: remaining_cards)
      game.forecasts.create!(turn_nr: game.turn_nr)
    end
    @static_ids = game.unused_infection_card_city_staticids.last(6)
  end

  def update
    staticids = game.unused_infection_card_city_staticids
    staticids.pop(6)
    staticids += params[:city_staticids]
    game.update!(unused_infection_card_city_staticids: staticids)
  end

  private

  def check_for_potential_create_errors
    render json: { error: create_error_message } if create_error_message
  end

  def check_for_potential_update_errors
    render json: { error: update_error_message } if update_error_message
  end

  def create_error_message
    @create_error_message ||=
      begin
        if forecast_card.nil? && !forecast_performed_this_turn?
          I18n.t("player_actions.must_own_card")
        end
      end
  end

  def update_error_message
    @update_error_message ||=
      begin
        case
        when forecast&.turn_nr != game.turn_nr
          I18n.t("errors.not_authorized")
        when bad_staticids?
          I18n.t("forecasts.bad_staticids")
        end
      end
  end

  def forecast_card
    current_player.events.find(&:forecast?)
  end

  def forecast_performed_this_turn?
    forecast&.turn_nr == game.turn_nr
  end

  def remaining_cards
    current_player.cards_composite_ids - [forecast_card.composite_id]
  end

  def forecast
    game.forecasts.last
  end

  def bad_staticids?
    game.unused_infection_card_city_staticids.last(6).sort !=
      params[:city_staticids].to_a.sort
  end
end
