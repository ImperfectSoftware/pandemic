class CharterFlightsController < PlayerActionsController
  def create
    CreateMovement.new(
      game: game,
      player: current_player,
      from: current_player.location_staticid,
      to: player_card.staticid
    ).call
    current_player.update!(cards_composite_ids: remaining_player_cards)
    send_game_broadcast
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if !current_player.owns_card?(current_player.location)
          I18n.t("player_actions.must_own_card")
        elsif !player_card
          I18n.t("player_actions.city_staticid")
        end
      end
  end

  def player_card
    @player_card ||= City.find(params[:city_staticid])
  end

  def remaining_player_cards
    current_player.cards_composite_ids - [
      current_player.movements.last.from_location.composite_id
    ]
  end
end
