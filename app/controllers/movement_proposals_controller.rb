class MovementProposalsController < PlayerActionsController
  def create
    proposal = current_player.created_movement_proposals.create!(
      player_id: params[:player_id],
      city_staticid: params[:city_staticid],
      turn_nr: game.turn_nr,
      game: game,
      accepted: false,
      airlift: false
    )
    send_movement_proposal_broadcast(proposal)
  end

  def update
    if params[:accepted]
      command = CreateMovementFromProposal
        .call(movement_proposal, current_player)
      if command.errors.any?
        render json: { error: command.errors[:allowed].first }
      end
    end
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
      .include?(city_staticid)
  end

  def other_player_at_destination?
    game.players.map(&:location).map(&:staticid)
      .include?(city_staticid)
  end

  def puppet_player
    @puppet_player ||= game.players.find_by(id: player_id)
  end

  def movement_proposal
    @movement_proposal ||= game.movement_proposals.find_by(id: params[:id])
  end

  def city_staticid
    params[:city_staticid]
  end

  def location
    City.find(city_staticid)
  end

  def player_id
    params[:player_id] || movement_proposal.player_id
  end

  def airlift_card
    SpecialCard.events.find(&:airlift?)
  end

  def place_airlift_card_in_game_discarded_special_player_cards
    game.discarded_special_player_card_ids << airlift_card.staticid
    game.save!
  end

  def discard_airlift_card_from_movement_proposal_creator
    movement_proposal.creator.cards_composite_ids
      .delete(airlift_card.composite_id)
    movement_proposal.creator.save!
  end

  def send_movement_proposal_broadcast(proposal)
    ActionCable.server.broadcast(
      "game_channel:#{game.id}",
      movement_proposal_notification: true,
      payload: {
        id: proposal.id,
        city_name: location.name,
        puppet_username: puppet_player.user.username,
        proponent_username: current_user.username
      }
    )
  end
end
