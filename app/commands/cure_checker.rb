class CureChecker
  prepend SimpleCommand

  attr_reader :game, :player

  def initialize(game:, player:)
    @game = game
    @player = player
  end

  def call
    return no_response unless player.at_research_station?
    return no_response unless enough_cards_to_discover_cure
    return no_response unless player.has_actions_left?
    return yes_response
  end

  private

  def most_city_cards
    return OpenStruct.new(count: 0) if player.cities.count == 0
    @most_city_cards ||=
      begin
        pair = player.cities.group_by(&:color).map do |color, cities|
          [color, cities.count]
        end.sort do |(_, count_one), (_, count_two)|
          count_two <=> count_one
        end.first
        OpenStruct.new(color: pair.first, count: pair.last)
      end
  end

  def enough_cards_to_discover_cure
    most_city_cards.count >=
      if player.scientist?
        4
      else
        5
      end
  end

  def no_response
    OpenStruct.new(can_discover_cure: false, color: 'none')
  end

  def yes_response
    OpenStruct.new(can_discover_cure: true, color: most_city_cards.color)
  end
end
