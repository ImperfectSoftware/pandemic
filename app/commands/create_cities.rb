class CreateCities
  prepend SimpleCommand

  def initialize(game:, user:)
    @game = game
    @user = user
  end

  def allowed?
    if @game.owner != @user
      errors.add(
        :authorization,
        I18n.t("authorization.create_city_not_allowed")
      )
      false
    end
    true
  end

  def call
    return unless allowed?
    City.create(city_attributes)
  end

  private

  def city_attributes
    WorldGraph.cities.map do |city|
      { staticid: city.staticid, game_id: @game.id }
    end
  end

end
