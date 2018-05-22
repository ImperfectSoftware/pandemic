class CreateMovement
  prepend SimpleCommand

  attr_reader :player, :game, :from, :to

  def initialize(player:, game:, from:, to:)
    @player = player
    @game = game
    @from = from
    @to = to
  end

  def call
    player.movements.create!(
      from_city_staticid: from,
      to_city_staticid: to
    )
    player.update!(location_staticid: to)
    game.increment!(:actions_taken)
  end
end
