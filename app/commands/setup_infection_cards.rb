class SetupInfectionCards
  prepend SimpleCommand

  def call
    OpenStruct.new(
      used_infection_card_city_staticids: used,
      unused_infection_card_city_staticids: cities_staticids,
      infections: infections
    )
  end

  private

  def cities_staticids
    @cities_staticids ||= WorldGraph.cities.map(&:staticid).shuffle
  end

  def infections
    @infections ||= {}.tap do |hash|
      1.upto(3).each do |count|
        cities_staticids.pop(3).each do |staticid|
          hash[staticid] = count
        end
      end
    end
  end

  def used
    infections.keys
  end

end
