class ShareKnowledgeChecker
  prepend SimpleCommand

  attr_reader :game, :city_staticid

  def initialize(game:, city_staticid:)
    @game = game
    @city_staticid = city_staticid
  end

  def call
    game.players.where(location_staticid: city_staticid).map(&:cities).flatten
      .map(&:staticid).include?(city_staticid)
  end
end
