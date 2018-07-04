class Games::PossibleActionsController < ApplicationController
  helper_method :can_drive, :can_direct_flight, :can_charter_flight, :can_treat,
    :can_shuttle_flight, :can_build_research_station, :cure_checker,
    :can_remove_research_station, :current_player,
    :display_government_grant_option, :operations_expert_flight

  def show
  end

  private

  def can_drive
    @can_drive ||= LineMovementChecker.call(
      player: current_player,
      city_staticid: params[:city_staticid]
    ).result
  end

  def can_direct_flight
    DirectFlightChecker.call(
      player: current_player,
      city_staticid: params[:city_staticid]
    ).result
  end

  def can_charter_flight
    CharterFlightChecker.call(
      player: current_player,
      city_staticid: params[:city_staticid]
    ).result
  end

  def can_shuttle_flight
    ShuttleFlightChecker.call(
      player: current_player,
      city_staticid: params[:city_staticid]
    ).result
  end

  def can_build_research_station
    ResearchStationChecker.call(
      player: current_player,
      city_staticid: params[:city_staticid]
    ).result
  end

  def can_remove_research_station
    game.has_research_station_at?(city_staticid: params[:city_staticid]) &&
      game.research_stations.count == 6
  end

  def cure_checker
    @cure_checker ||= CureChecker.call(game: game, player: current_player)
      .result
  end

  def operations_expert_flight
    return false unless current_player.operations_expert?
    return false unless current_player == active_player
    return false if current_player.location.staticid == params[:city_staticid]
    return false if current_player.location.neighbors_staticids
      .include?(params[:city_staticid])
    true
  end

  def can_treat
    @can_treat ||=
      begin
        result = {}
        CureMarker.colors.keys.map do |color|
          result[color] = TreatDiseaseChecker.call(
            player: current_player,
            game: game,
            color: color,
            city_staticid: params[:city_staticid]
          ).result
        end
        result
      end
  end

  def display_government_grant_option
    if params[:city_staticid] != current_player.location.staticid &&
        game.has_research_station_at?(city_staticid: params[:city_staticid])
      return false
    end
    current_player.owns_government_grant?
  end
end
