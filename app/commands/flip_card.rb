class FlipCard
  prepend SimpleCommand

  def initialize(game:, player:)
    @game = game
    @player = player
  end

  def call
    validate_command
    return if errors.any?
    if player_card.blank?
      @game.finished!
    else
      @game.increment!(:flipped_cards_nr)
      handle_card
    end
  end

  private

  def handle_card
    if player_card.storable?
      @player.cards_composite_ids << player_card.composite_id
      @player.save!
    else
      @game.discarded_special_player_card_ids << player_card.staticid
      @game.save!
      start_stage_one_epidemic
    end
  end

  def start_stage_one_epidemic
    StageOneEpidemic.new(game: @game).call
  end

  def player_card
    @player_card ||=
      begin
        composite_id = @game.unused_player_card_ids.pop
        @game.save!
        PlayerCard.find_by_composite_id(composite_id)
      end
  end

  def validate_command
    if @game.flipped_cards_nr == 2
      errors.add(:allowed, I18n.t("player_actions.flipped_max"))
    end
    if not_active_player
      errors.add(:allowed, I18n.t("player_actions.bad_turn"))
    end
  end

  def not_active_player
    GetActivePlayer.new(
      player_ids: @game.player_turn_ids,
      turn_nr: @game.turn_nr
     ).call.result != @player.id
  end
end
