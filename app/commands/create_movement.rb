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

    infections.each do |infection|
      cure_marker = @game.cure_markers.find_by(color: infection.color)
      if @player.medic? && cure_marker&.cured?
        command = TreatDiseases.new(
          game: @game,
          cure_marker: cure_marker,
          infection: infection,
          medic: true
        )
        command.call
      end
    end
  end

  private

  def infections
    @infections ||= @game.infections.where(city_staticid: @to)
  end

  def city
    City.find(@to)
  end
end
