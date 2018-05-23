class MovementProposalsController < PlayerActionsController
  before_action :check_for_potential_update_errors, only: :update

  def create
    current_player.created_movement_proposals.create!(
      player_id: params[:player_id],
      city_staticid: params[:city_staticid],
      turn_nr: game.turn_nr,
      game: game,
      accepted: false,
      airlift: using_airlift?
    )
  end

  def update
    if params[:accepted]
      movement_proposal.update!(accepted: true)
      CreateMovement.new(
        game: game,
        player: puppet_player,
        from: puppet_player.location_staticid,
        to: city_staticid
      ).call
      if movement_proposal.airlift?
        game.discarded_special_player_card_ids << airlift_card.composite_id
        game.decrement(:actions_taken)
        game.save!
        puppet_player.update!(cards_composite_ids: remaining_cards)
      end
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
        when !destination_is_a_neighbor? && !other_player_at_destination?
          I18n.t("movement_proposals.not_allowed")
        when !current_player.dispatcher? && !using_airlift?
          I18n.t("dispatcher.must_be_a_dispatcher")
        end
      end
  end

  def update_error_message
    @update_error_message ||=
      begin
        case
        when !params[:accepted]
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
end