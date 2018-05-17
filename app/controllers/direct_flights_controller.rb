class DirectFlightsController < PlayerActionsController

  def create
    CreateMovement.new(
      game: game,
      player: current_player,
      from: current_player.current_location_staticid,
      to: player_card.staticid
    ).call
    current_player.update!(cards_composite_ids: remaining_player_cards)
  end

  private

  def create_error_message
    I18n.t("player_actions.city_card_composite_id") unless player_card
  end

  def player_card
    @player_card ||= current_player.find_player_city_card(
      composite_id: params[:player_card_composite_id].to_s
    )
  end

  def remaining_player_cards
    current_player.cards_composite_ids - [player_card.composite_id]
  end
end
