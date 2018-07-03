class Games::DiscardCityCardsController < ApplicationController
  include GameBroadcast

  def destroy
    current_player.update!(cards_composite_ids: remaining_cards)
    send_game_broadcast
  end

  private

  def city_card
    City.find(params[:city_staticid])
  end

  def remaining_cards
    current_player.cards_composite_ids - [city_card&.composite_id]
  end
end
