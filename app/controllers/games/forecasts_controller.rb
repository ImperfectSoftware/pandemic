class Games::ForecastsController < ApplicationController
  include GameBroadcast
  before_action :check_for_potential_create_errors, only: :create
  before_action :check_for_potential_update_errors, only: :update

  helper_method :cities
  attr_reader :cities

  def create
    game.forecasts.find_or_create_by(turn_nr: game.turn_nr)
    @cities = City.find_from_staticids(staticids)
  end

  def update
    staticids = game.unused_infection_card_city_staticids
    staticids.pop(6)
    staticids += params[:city_staticids]
    game.update!(unused_infection_card_city_staticids: staticids)
    send_generic_notification
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if forecast_card.nil?
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

  def forecast
    game.forecasts.last
  end

  def bad_staticids?
    game.unused_infection_card_city_staticids.last(6).sort !=
      params[:city_staticids].to_a.sort
  end

  def staticids
    game.unused_infection_card_city_staticids.last(6).reverse
  end

  def send_generic_notification
    city_names = City.find_from_staticids(staticids).map(&:name).join(", ")
    message = I18n.t(
      "forecasts.updated",
      username: current_user.username,
      cards: city_names
    )
    send_generic_notification_broadcast(message)
  end
end
