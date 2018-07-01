class Games::PossiblePlayerActionsController < ApplicationController
  helper_method :cities, :locations, :airlift_locations,
    :operations_expert_locations
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
    return [] unless current_player.dispatcher?
    return [] if current_player == other_player
    (game.players.map(&:location) + other_player.location.neighbors).uniq
      .map do |location|
        OpenStruct.new(name: location.name, staticid: location.staticid)
      end
  end

  def airlift_locations
    return [] unless current_player
      .owns_card?(SpecialCard.events.find(&:airlift?))
    (WorldGraph.cities - [other_player.location]).map do |location|
        OpenStruct.new(name: location.name, staticid: location.staticid)
    end
  end

  def operations_expert_locations
    return [] unless current_player.operations_expert? && game
      .has_research_station_at?(city_staticid: current_player.location.staticid)
    (WorldGraph.cities - [current_player.location]).map do |location|
        OpenStruct.new(name: location.name, staticid: location.staticid)
    end.sort_by(&:name)
  end
end
