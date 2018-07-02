class ResearchStationChecker
  prepend SimpleCommand

  attr_reader :player, :city_staticid
  def initialize(player:, city_staticid:)
    @player = player
    @city_staticid = city_staticid
  end

  def call
    return false unless player.has_actions_left?
    return false unless player.location == location
    return true if player.operations_expert?
    return false unless player.owns_card?(location)
    true
  end

  private

  def location
    City.find(city_staticid)
  end
end
