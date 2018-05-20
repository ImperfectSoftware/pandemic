class OperationsExpertFlightsController < PlayerActionsController

  def create
    CreateMovement.new(
      game: game,
      player: current_player,
      from: current_player.current_location_staticid,
      to: params[:destination_city_staticid]
    ).call
    current_player.update!(cards_composite_ids: remaining_player_cards)
    current_player.operations_expert_actions.create!(turn_nr: game.turn_nr)
  end

  private

  def create_error_message
    @create_error_message ||=
      begin
        if missing_params
          I18n.t("errors.missing_param")
        elsif !current_player.operations_expert?
          I18n.t("player_actions.must_be_an_operations_expert")
        elsif !departure_city_is_a_research_station?
          I18n.t(
            'player_actions.city_with_no_station',
            name: current_player.location.name
          )
        elsif !player_card
          I18n.t("player_actions.must_own_card")
        elsif action_already_performed_this_turn?
          I18n.t("operations_expert.one_action_per_turn")
        end
      end
  end

  def player_card
    @player_card ||= current_player.city_card_from_inventory(
      staticid: params[:discarded_city_staticid].to_s
    )
  end

  def action_already_performed_this_turn?
    !!current_player.operations_expert_actions.find_by(turn_nr: game.turn_nr)
  end

  def remaining_player_cards
    current_player.cards_composite_ids - [player_card.composite_id]
  end

  def departure_city_is_a_research_station?
    game.has_research_station_at?(
      city_staticid: current_player.current_location_staticid
    )
  end

  def missing_params
    params[:destination_city_staticid].blank? ||
      params[:discarded_city_staticid].blank?
  end
end
