class DirectFlightsController < PlayerActionsController
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
    I18n.t("player_actions.city_staticid") unless player_card
  end

  def player_card
    return location if current_player.owns_card?(location)
  end

  def remaining_player_cards
    current_player.cards_composite_ids - [player_card.composite_id]
  end

  def location
    City.find(params[:city_staticid])
  end
end
