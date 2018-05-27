class GetSpecialCards
  prepend SimpleCommand

  def initialize(game:)
    @game = game
  end

  def call
    # We only allow the contingency planner to extract the cards that have been
    # used only once.
    @game.discarded_special_player_card_ids.group_by(&:itself).select do |k,v|
      v.count == 1
    end.keys
  end
end
