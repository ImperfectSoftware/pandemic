class MovementProposalsController < PlayerActionsController
  before_action :check_for_potential_update_errors, only: :update

  def create
    proposal = current_player.created_movement_proposals.create!(
      player_id: params[:player_id],
      city_staticid: params[:city_staticid],
      turn_nr: game.turn_nr,
      game: game,
      accepted: false,
      airlift: using_airlift?
    )
    send_movement_proposal_broadcast(proposal)
  end

  def update
    if params[:accepted]
      movement_proposal.update!(accepted: true)
      CreateMovement.new(
        game: game,
        player: puppet_player,
        from: puppet_player.location_staticid,
        to: city_staticid,
        airlift: movement_proposal.airlift?
      ).call
      if movement_proposal.airlift?
        game.discarded_special_player_card_ids << airlift_card.staticid
        game.save!
        movement_proposal.creator.update!(cards_composite_ids: remaining_cards)
      end
      send_game_broadcast
    end
  end

  private

  def check_for_potential_update_errors
    render json: { error: update_error_message } if update_error_message
  end

  def create_error_message
    @create_error_message ||=
      begin
        case
        when params[:city_staticid].blank? || params[:player_id].blank?
          I18n.t("errors.missing_param")
        when using_airlift?
          # we need to allow this action if city is specified
        when !destination_is_a_neighbor? && !other_player_at_destination?
          I18n.t("movement_proposals.not_allowed")
        when !current_player.dispatcher?
          I18n.t("dispatcher.must_be_a_dispatcher")
        end
      end
  end

  def update_error_message
    @update_error_message ||=
      begin
        case
        when !params[:accepted] || movement_proposal.airlift?
          # we don't need to check for errors if not accpeted
          # any city is allowed with airlift
        when puppet_player != current_player
          I18n.t("errors.not_authorized")
        when game.actions_taken == 4
          I18n.t("player_actions.no_actions_left")
        when !destination_is_a_neighbor? && !other_player_at_destination?
          I18n.t("movement_proposals.not_allowed")
        when movement_proposal.turn_nr != game.turn_nr
          I18n.t("movement_proposals.expired")
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
    params[:city_staticid] || movement_proposal.city_staticid
  end

  def location
    City.find(city_staticid)
  end

  def player_id
    params[:player_id] || movement_proposal.player_id
  end

  def using_airlift?
    !!current_player.events.find(&:airlift?) && params[:airlift]
  end

  def airlift_card
    SpecialCard.events.find(&:airlift?)
  end

  def remaining_cards
    puppet_player.cards_composite_ids - [airlift_card.composite_id]
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
