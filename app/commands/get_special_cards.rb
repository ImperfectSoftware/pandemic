class GetSpecialCards
  prepend SimpleCommand

  attr_reader :game

  def initialize(game:)
    @game = game
  end

  # We only allow the contingency planner to extract the cards that have been
  # used only once.
  #
  # We only want to display the event cards as discarded if they have been
  # discarded and not picked up by the contingency planer. To do that, we find
  # all the cards that have not been discarded more than once (This scenario
  # can happen when the contingency planer played an event card he previously
  # picked up). We then remove the cards that the contingency planer has in his
  # inventory (If the event card is both discarded and in the contingency
  # planer's inventory, it must have been picked up in a previous action).
  def call
    event_staticids.map do |staticid|
      SpecialCard.find(staticid)
    end
  end

  private

  def event_staticids
    if contingency_planer
      discarded_events_staticids_used_once -
        contingency_planer.events.map(&:staticid)
    else
      game.discarded_special_player_card_ids
    end
  end

  def discarded_events_staticids_used_once
    game.discarded_special_player_card_ids.group_by(&:itself).select do |k,v|
      v.count == 1
    end.keys
  end

  def contingency_planer
    @contingency_planer ||= game.players.contingency_planer.first
  end
end
