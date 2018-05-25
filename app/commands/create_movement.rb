class CreateMovement
  prepend SimpleCommand

  def initialize(player:, game:, from:, to:, airlift: false)
    @player = player
    @game = game
    @from = from
    @to = to
    @airlift = airlift
  end

  def call
    @player.movements.create!(
      from_city_staticid: @from,
      to_city_staticid: @to
    )
    @player.update!(location_staticid: @to)
    @game.increment!(:actions_taken) unless @airlift
  end
end
