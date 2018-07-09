class CreateMovementFromProposal
  include GameBroadcast

  prepend SimpleCommand

  private

  delegate :game, :airlift?, :creator, :player, to: :proposal

  attr_reader :proposal, :requester
  def initialize(proposal, requester)
    @proposal = proposal
    @requester = requester
  end

  def call
    validate_command
    return if errors.any?
    proposal.update!(accepted: true)
    CreateMovement
      .call(game: game, player: player, from: from, to: to, airlift: airlift?)
    if airlift?
      game.discard_event!(event)
      creator.cards_composite_ids.delete(event.composite_id)
      creator.save!
    end
    send_game_broadcast
  end

  def from
    player.location_staticid
  end

  def to
    proposal.city_staticid
  end

  def event
    SpecialCard.events.find(&:airlift?)
  end

  # Private: Validate that creating a movement is allowed.
  #
  # A movement proposal originating from an airlift event only needs to
  # validated that the correct player is accepting the proposal.
  #
  # When the movement proposal does not originate from an airlift event card we
  # also need to validate the following:
  #
  # Validate that there are enough actions left to be able to apply the
  # proposal.
  #
  # Ensure that the proposal was created during the same round/turn the player
  # is accepting the proposal.
  #
  # The dispatcher can act as another player and create a movement proposal to a
  # neighboring location. The dispatcher can also move the player to a location
  # with another existing player. We need to validated that the location the
  # proposal was created for is stil valid. A location from a movement proposal
  # could be invalid if the player moved to another location since the movement
  # proposal was created.
  def validate_command
    if requester != player
      errors.add(:allowed, I18n.t("errors.not_authorized"))
    end
    unless airlift?
      if game.actions_taken == 4
        errors.add(:allowed, I18n.t("player_actions.no_actions_left"))
      end
      if proposal.turn_nr != game.turn_nr
        errors.add(:allowed, I18n.t("movement_proposals.expired"))
      end
      if destination_is_not_a_neighbor? && another_player_is_not_at_destination?
        errors.add(:allowed, I18n.t("movement_proposals.not_allowed"))
      end
    end
  end

  def destination_is_not_a_neighbor?
    !player.location.neighbors_staticids.include?(to)
  end

  def another_player_is_not_at_destination?
    !game.players.map(&:location).map(&:staticid).include?(to)
  end
end
