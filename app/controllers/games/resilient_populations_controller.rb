class Games::ResilientPopulationsController < ApplicationController
  before_action :check_for_authorization, only: [:show]
  before_action :check_for_potential_create_errors, only: :create

  def show
  end

  def create
  end

  private

  def check_for_authorization
    if !game.between_epidemic_stages?
      render json: { error: I18n.t("errors.not_authorized") }
    end
  end

  helper_method :used_cards
  def used_cards
    @used_cards ||= game.unused_infection_card_city_staticids
      .reverse[0, game.nr_of_intensified_cards]
      .sort
  end
end
