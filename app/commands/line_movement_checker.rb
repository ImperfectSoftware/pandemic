class LineMovementChecker
  prepend SimpleCommand

  attr_reader :player, :city_staticid

  def initialize(player:, city_staticid:)
    @player = player
    @city_staticid = city_staticid
  end

  def call
    return false unless player.has_actions_left?
    return false unless city_is_a_neighbor?
    true
  end

  private

  def city_is_a_neighbor?
    player.location.neighbors_staticids.include?(city_staticid)
  end
end
