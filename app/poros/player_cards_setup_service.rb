class PlayerCardsSetupService
  attr_reader :player_ids, :number_of_epidemic_cards

  def initialize(player_ids:, number_of_epidemic_cards:)
    @player_ids = player_ids
    @number_of_epidemic_cards = number_of_epidemic_cards
  end

  def call
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

  def epidemic_cards
    [ SpecialCard.epidemic_card.composite_id ] *
      number_of_epidemic_cards
  end

  def number_of_cards_per_hand
    @number_of_cards_per_hand ||= { 2 => 4, 3 => 3 , 4 => 2 }[player_ids.count]
  end

  def player_cards_with_epidemic_cards
    player_cards.in_groups(number_of_epidemic_cards).map do |group|
      (group.compact + [SpecialCard.epidemic_card.composite_id]).shuffle
    end.flatten
  end
end
