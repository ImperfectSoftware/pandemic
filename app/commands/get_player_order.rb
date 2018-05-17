class GetPlayerOrder
  prepend SimpleCommand

  def initialize(player_hands:)
    @player_hands = player_hands
  end

  def call
    @player_hands.sort_by do |id, hand|
      hand.map do |composite_id|
        PlayerCard.find_by_composite_id(composite_id)
      end.select do |card|
        card.is_a?(City)
      end.map(&:population).max || 0
    end.map(&:first)
  end

end
