class CreateMovement
  prepend SimpleCommand

  attr_reader :player, :game, :from, :to, :by_dispatcher

  def initialize(player:, game:, from:, to:, by_dispatcher: false)
    @player = player
    @game = game
    @from = from
    @to = to
    @by_dispatcher = by_dispatcher
  end

  def call
    player.movements.create!(
      from_city_staticid: from,
      to_city_staticid: to,
      by_dispatcher: by_dispatcher
    )
    player.update!(location_staticid: to)
    game.increment!(:actions_taken)
  end
end
