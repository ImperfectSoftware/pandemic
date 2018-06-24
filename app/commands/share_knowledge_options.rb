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
    return [] if current_player.location != other_player.location
    sharable_cities(other_player)
  end

  def give_cities
    return [] if current_player.location != other_player.location
    sharable_cities(current_player)
  end

  def sharable_cities(player)
    if player.researcher?
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
