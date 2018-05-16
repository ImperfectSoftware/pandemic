class ShuttleFlightsController < ApplicationController
  def create
    if current_player != active_player
      render json: { error: I18n.t('player_actions.not_your_turn') }
      return
    end
    if game.no_actions_left?
      render json: { error: I18n.t('player_actions.no_actions_left') }
      return
    end
    if current_player.has_too_many_cards?
      render json: { error: I18n.t('player_actions.discard_player_city_card') }
      return
    end

    if params[:city_staticid].blank?
      render json: { error: I18n.t('shuttle_flights.city_staticid') }
      return
    end
    if !departure_city_is_a_research_station?
      render json: {
        error: I18n.t('shuttle_flights.departure_city_not_a_research_station')
      }
      return
    end
    if !destination_city_is_a_research_station?
      render json: {
        error: I18n.t('shuttle_flights.destination_city_not_a_research_station')
      }
      return
    end
    current_player.movements.create!(
      from_city_staticid: current_player.current_location_staticid,
      to_city_staticid: params[:city_staticid],
      by_dispatcher: false
    )
    current_player.update!(current_location_staticid: params[:city_staticid])
    game.increment!(:actions_taken)
  end

  private

  def current_player
    @current_player ||= current_user.players.find_by(game: game)
  end

  def active_player
    @active_player ||= game.players.find_by(id: active_player_id)
  end

  def game
    @game ||= current_user.games.find_by(id: params[:game_id])
  end

  def active_player_id
    GetActivePlayer.new(
      player_ids: game.player_turn_ids,
      turn_nr: game.turn_nr
    ).call.result
  end

  def departure_city_is_a_research_station?
    game.has_research_station_at?(
      city_staticid: current_player.current_location_staticid
    )
  end

  def destination_city_is_a_research_station?
    game.has_research_station_at?(
      city_staticid: params[:city_staticid]
    )
  end

end
