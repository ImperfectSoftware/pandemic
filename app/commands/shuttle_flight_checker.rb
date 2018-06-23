class ShuttleFlightChecker
  prepend SimpleCommand

  attr_reader :player, :city_staticid
  def initialize(player:, city_staticid:)
    @player = player
    @city_staticid = city_staticid
  end

  def call
    return false unless player.has_actions_left?
    return false if player.location == location
    return false unless player.at_research_station?
    return false unless destination_at_research_station?
    true
  end

  private

  def location
    City.find(city_staticid)
  end

  def destination_at_research_station?
    player.game.has_research_station_at?(city_staticid: city_staticid)
  end
end
