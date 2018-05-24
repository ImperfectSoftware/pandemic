class Games::DiscardCityCardsController < ApplicationController

  def destroy
    current_player.update!(cards_composite_ids: remaining_cards)
  end

  private

  def current_player
    @current_player ||= current_user.players.find_by(game: game)
  end

  def game
    @game ||= current_user.games.find_by(id: params[:game_id])
  end

  def city_card
    City.find(params[:city_staticid])
  end

  def remaining_cards
    current_player.cards_composite_ids - [city_card&.composite_id]
  end
end
