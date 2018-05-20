class GetUniqueRole
  prepend SimpleCommand

  def initialize(players:)
    @players = players
  end

  def call
    (Player.roles.keys - @players.map(&:role)).sample
  end
end
