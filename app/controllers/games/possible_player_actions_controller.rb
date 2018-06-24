class Games::PossiblePlayerActionsController < ApplicationController
  helper_method :cities
  attr_reader :cities

  def show
    @cities = ShareKnowledgeOptions.call(
      game: game,
      current_player: current_player,
      other_player: other_player
    ).result
  end

  private

  def other_player
    game.players.find(params[:player_id])
  end
end
