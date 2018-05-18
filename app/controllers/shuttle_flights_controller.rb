class ShuttleFlightsController < PlayerActionsController

  def create
    CreateMovement.new(
      game: game,
      player: current_player,
      from: current_player.current_location_staticid,
      to: params[:city_staticid]
    ).call
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if params[:city_staticid].blank?
          I18n.t('player_actions.city_staticid')
        elsif !departure_city_is_a_research_station?
          I18n.t(
            'shuttle_flights.city_with_no_station',
            name: departure_city.name
          )
        elsif !destination_city_is_a_research_station?
          I18n.t(
            'shuttle_flights.city_with_no_station',
            name: destination_city.name
          )
        end
      end
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

  def destination_city
    @destination_city ||= City.find(params[:city_staticid])
  end

  def departure_city
    current_player.current_location
  end
end
