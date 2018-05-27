class StageTwoEpidemic
  prepend SimpleCommand

  def initialize(game:, player:)
    @game = game
    @player = player
  end

  def call
    validate_command
    return if errors.any?
    infection_rate.times do
      staticid = @game.unused_infection_card_city_staticids.pop
      PlaceInfectionCommand.new(game: @game, staticid: staticid, quantity: 1)
        .call
      @game.used_infection_card_city_staticids << staticid
    end
    @game.nr_of_intensified_cards = 0
    @game.save!
  end

  private

  def infection_rate
    GetInfectionRate.new(nr_of_epidemic_cards: epidemic_cards.count).call.result
  end

  def epidemic_cards
    @game.discarded_special_player_card_ids.select do |staticid|
      SpecialCard.epidemic_card.staticid == staticid
    end
  end

  def validate_command
    case
    when not_active_player
      errors.add(:allowed, I18n.t('player_actions.bad_turn'))
    when !@game.between_epidemic_stages?
      errors.add(:allowed, I18n.t("errors.not_authorized"))
    end
  end

  def not_active_player
    GetActivePlayer.new(
      player_ids: @game.players.map(&:id),
      turn_nr: @game.turn_nr
     ).call.result != @player.id
  end
end
