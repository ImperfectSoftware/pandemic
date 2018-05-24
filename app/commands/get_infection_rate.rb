class GetInfectionRate
  prepend SimpleCommand

  def initialize(nr_of_epidemic_cards:)
    @count = nr_of_epidemic_cards
  end

  def call
    rate[@count]
  end

  private

  def rate
    [2,2,2,3,3,4,4]
  end
end
