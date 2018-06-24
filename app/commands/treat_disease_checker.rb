class TreatDiseaseChecker
  prepend SimpleCommand

  attr_reader :game, :player, :city_staticid, :color
  def initialize(game:, player:, city_staticid:, color:)
    @game = game
    @player = player
    @city_staticid = city_staticid
    @color = color
  end

  def call
    return false unless player.has_actions_left?
    return false unless player.location.staticid == city_staticid
    return false unless infection && infection.quantity > 0
    true
  end

  private

  def infection
    game.infections.find_by(color: color, city_staticid: city_staticid)
  end

end
