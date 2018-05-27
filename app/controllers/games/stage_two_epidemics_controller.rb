class Games::StageTwoEpidemicsController < ApplicationController
  def create
    command = StageTwoEpidemic.new(game: game, player: current_player)
    command.call
    if command.errors.any?
      render json: { error: command.errors[:allowed].first }
    end
  end
end
