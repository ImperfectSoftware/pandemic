class StageOneEpidemic
  prepend SimpleCommand

  def initialize(game:)
    @game = game
  end

  def call
    city_staticid = @game.unused_infection_card_city_staticids.shift
    cards = @game.used_infection_card_city_staticids.push(city_staticid)
    cards.shuffle!
    @game.update!(
      unused_infection_card_city_staticids: unused_infection_cards + cards,
      used_infection_card_city_staticids: [],
      nr_of_intensified_cards: cards.count
    )
    PlaceInfectionCommand
      .new(game: @game, staticid: city_staticid, quantity: 3).call
    StageTwoEpidemic.new(game: @game).call if should_start_stage_two?
  end

  private

  def unused_infection_cards
    @game.unused_infection_card_city_staticids
  end

  def should_start_stage_two?
    @game.players.map(&:events).flatten.select do |event|
      event.forecast? || event.resilient_population?
    end.blank?
  end
end
