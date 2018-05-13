Fabricator(:game) do
  started { false }
  owner { Fabricate(:user) }
  after_create do |game, _|
    Fabricate(:player, user: game.owner, game: game)
  end
end

Fabricator(:game_with_cities, class_name: Game) do
  started { false }
  owner { Fabricate(:user) }
  after_create do |game, _|
    CreateCities.new(game: game, user: game.owner).call
  end
end
