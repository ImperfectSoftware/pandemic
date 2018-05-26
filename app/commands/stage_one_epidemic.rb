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
  end

  private

  def unused_infection_cards
    @game.unused_infection_card_city_staticids
  end
end
