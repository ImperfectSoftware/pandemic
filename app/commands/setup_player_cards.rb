class SetupPlayerCards
  prepend SimpleCommand

  attr_reader :player_ids, :nr_of_epidemic_cards

  def initialize(player_ids:, nr_of_epidemic_cards:)
    @player_ids = player_ids
    @nr_of_epidemic_cards = nr_of_epidemic_cards.to_i
  end

  def call
    if !player_ids.count.between?(2, 4)
      errors.add(:setup, I18n.t("games.minimum_number_of_players"))
    end
    if !nr_of_epidemic_cards.between?(4, 6)
      errors.add(:setup, I18n.t("games.incorrect_nr_of_epidemic_cards"))
    end
    return if errors.any?

    OpenStruct.new(
      player_hands: player_hands,
      player_cards: player_cards_with_epidemic_cards
    )
  end

  private

  def player_cards
    @player_cards ||=
      (WorldGraph.composite_ids + SpecialCard.events_composite_ids).shuffle
  end

  def player_hands
    @player_hands ||= player_ids.reduce(Hash.new) do |result, player_id|
      result.merge({ player_id => player_cards.pop(number_of_cards_per_hand) })
    end
  end

  def number_of_cards_per_hand
    @number_of_cards_per_hand ||= { 2 => 4, 3 => 3 , 4 => 2 }[player_ids.count]
  end

  def player_cards_with_epidemic_cards
    player_cards.in_groups(nr_of_epidemic_cards).map do |group|
      (group.compact + [SpecialCard.epidemic_card.composite_id]).shuffle
    end.flatten
  end
end
