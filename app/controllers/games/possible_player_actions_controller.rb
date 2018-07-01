class Games::PossiblePlayerActionsController < ApplicationController
  helper_method :cities, :locations
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

  def locations
    return [] if current_player == other_player
    (game.players.map(&:location) + other_player.location.neighbors).uniq
      .map do |location|
        OpenStruct.new(name: location.name, staticid: location.staticid)
      end
  end
end
