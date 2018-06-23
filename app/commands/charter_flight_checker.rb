class CharterFlightChecker
  prepend SimpleCommand

  attr_reader :player
  def initialize(player:)
    @player = player
  end

  def call
    return false unless player.has_actions_left?
    player.owns_card?(player.location)
  end
end
