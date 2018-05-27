class StageTwoEpidemic
  def initialize(game:)
    @game = game
  end

  def call
    infection_rate.times do
      staticid = @game.unused_infection_card_city_staticids.pop
      PlaceInfectionCommand.new(game: @game, staticid: staticid, quantity: 1)
        .call
      @game.used_infection_card_city_staticids << staticid
    end
    @game.nr_of_intensified_cards = 0
    @game.save!
  end

  private

  def infection_rate
    GetInfectionRate.new(nr_of_epidemic_cards: epidemic_cards.count).call.result
  end

  def epidemic_cards
    @game.discarded_special_player_card_ids.select do |staticid|
      SpecialCard.epidemic_card.staticid == staticid
    end
  end
end
