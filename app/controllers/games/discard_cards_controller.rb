class Games::DiscardCardsController < ApplicationController
  include GameBroadcast

  def destroy
    current_player.update!(cards_composite_ids: remaining_cards)
    send_game_broadcast
  end

  private

  def remaining_cards
    current_player.cards_composite_ids - [params[:composite_id]]
  end
end
