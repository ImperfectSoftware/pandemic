class ShuttleFlightsController < PlayerActionsController

  def create
    if create_error_message
      render json: { error: create_error_message }
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

  def create_error_message
    @create_error_message ||=
      begin
        if params[:city_staticid].blank?
          I18n.t('shuttle_flights.city_staticid')
        elsif !departure_city_is_a_research_station?
          I18n.t('shuttle_flights.departure_city_not_a_research_station')
        elsif !destination_city_is_a_research_station?
          I18n.t('shuttle_flights.destination_city_not_a_research_station')
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
end
