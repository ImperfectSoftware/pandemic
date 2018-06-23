class Games::PossibleActionsController < ApplicationController
  helper_method :can_drive, :can_direct_flight, :can_charter_flight,
    :can_shuttle_flight, :can_build_research_station,
    :can_remove_research_station, :cure_checker

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
    current_player.at_research_station?
  end

  def cure_checker
    @cure_checker ||= CureChecker.call(game: game, player: current_player)
      .result
  end
end
