class Games::DiscardCityCardsController < ApplicationController

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

  def send_game_broadcast
    payload = JSON.parse(ApplicationController.new.render_to_string(
      'games/show',
      locals: { game: StartedGameDecorator.new(game) }
    ))
    ActionCable.server.broadcast(
      "game_channel:#{game.id}",
      game_update: true,
      game: payload
    )
  end
end
