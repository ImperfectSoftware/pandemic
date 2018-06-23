class ResearchStationChecker
  prepend SimpleCommand

  attr_reader :player, :city_staticid
  def initialize(player:, city_staticid:)
    @player = player
    @city_staticid = city_staticid
  end

  def call
    return true if player.owns_card?(government_grant)
    return false unless player.has_actions_left?
    return true if player.operations_expert?
    return false unless player.owns_card?(location)
    true
  end

  private

  def government_grant
    SpecialCard.events.find(&:government_grant?)
  end

  def location
    City.find(city_staticid)
  end
end
