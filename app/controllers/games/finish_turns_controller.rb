class Games::FinishTurnsController < ApplicationController
  def create
    command = FlipCard.new(game: game, player: current_player)
    command.call
    if command.errors.any?
      render json: { error: command.errors[:allowed].first }
    end
  end
end
