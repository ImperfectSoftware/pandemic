class GetUniqueRole
  prepend SimpleCommand

  def initialize(players:)
    @players = players
  end

  def call
    (Role.all - @players.map(&:role)).sample
  end
end
