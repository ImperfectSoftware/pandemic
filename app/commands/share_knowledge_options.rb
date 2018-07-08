class ShareKnowledgeOptions
  prepend SimpleCommand

  attr_reader :game, :other_player, :current_player
  def initialize(game:, other_player:, current_player:)
    @game = game
    @other_player = other_player
    @current_player = current_player
  end

  def call
    OpenStruct.new(to_receive: receive_cities, to_give: give_cities)
  end

  private

  Struct.new('CityStruct', :name, :owner_username, :staticid)
  def receive_cities
    sharable_cities(other_player)
  end

  def give_cities
    sharable_cities(current_player)
  end

  def sharable_cities(player)
    return [] if current_player == other_player
    return [] if current_player.location != other_player.location
    if current_player.researcher? || other_player.researcher?
      player.cities.map do |city|
        Struct::CityStruct.new(city.name, player.user.username, city.staticid)
      end
    elsif player.owns_card?(city)
      [Struct::CityStruct.new(city.name, player.user.username, city.staticid)]
    else
      []
    end
  end

  def city
    other_player.location
  end
end
