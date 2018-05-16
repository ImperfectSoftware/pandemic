class LineMovementsController < PlayerActionsController

  def create
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
          I18n.t('player_actions.city_staticid')
        elsif !destination_is_a_neighbor?
          I18n.t('line_movements.destination_is_not_a_neighbor')
        end
      end
  end

  def destination_is_a_neighbor?
    current_player.current_location.neighbors_staticids
      .include?(params[:city_staticid])
  end
end
