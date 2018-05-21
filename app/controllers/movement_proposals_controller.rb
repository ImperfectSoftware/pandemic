class MovementProposalsController < PlayerActionsController
  def create
    current_player.created_movement_proposals.create!(
      player_id: params[:player_id],
      city_staticid: params[:city_staticid],
      turn_nr: game.turn_nr,
      game: game,
      accepted: false
    )
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        case
        when params[:city_staticid].blank? || params[:player_id].blank?
          I18n.t("errors.missing_param")
        when !destination_is_a_neighbor? && !other_player_at_destination?
          I18n.t("movement_proposals.not_allowed")
        when !current_player.dispatcher?
          I18n.t("dispatcher.must_be_a_dispatcher")
        end
      end
  end

  def destination_is_a_neighbor?
    puppet_player.location.neighbors_staticids
      .include?(params[:city_staticid])
  end

  def other_player_at_destination?
    game.players.map(&:location).map(&:staticid)
      .include?(params[:city_staticid])
  end

  def puppet_player
    @puppet_player ||= game.players.find_by(id: params[:player_id])
  end
end
