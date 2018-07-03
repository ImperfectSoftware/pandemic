class Games::FlipCardsController < ApplicationController
  include GameBroadcast

  def create
    command = FlipCard.new(game: game, player: current_player)
    command.call
    send_game_broadcast
    if command.errors.any?
      render json: { error: command.errors[:allowed].first }
    end
  end
end
