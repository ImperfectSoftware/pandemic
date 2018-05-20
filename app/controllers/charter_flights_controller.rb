class CharterFlightsController < PlayerActionsController
  def create
    CreateMovement.new(
      game: game,
      player: current_player,
      from: current_player.location_staticid,
      to: player_card.staticid
    ).call
    current_player.update!(cards_composite_ids: remaining_player_cards)
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if !player_owns_current_location?
          I18n.t("player_actions.must_own_card")
        elsif !player_card
          I18n.t("player_actions.city_card_composite_id")
        end
      end
  end

  def player_card
    @player_card ||= City
      .find_from_composite_id(params[:player_card_composite_id])
  end

  def player_owns_current_location?
    !!current_player.player_city_card_from_inventory(
      composite_id: current_player.location.composite_id
    )
  end

  def remaining_player_cards
    current_player.cards_composite_ids - [
      current_player.movements.last.from_location.composite_id
    ]
  end
end
