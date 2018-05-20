class LineMovementsController < PlayerActionsController

  def create
    CreateMovement.new(
      game: game,
      player: current_player,
      from: current_player.location_staticid,
      to: params[:city_staticid]
    ).call
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
    current_player.location.neighbors_staticids
      .include?(params[:city_staticid])
  end
end
