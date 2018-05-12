Fabricator(:game) do
  started { false }
  owner { Fabricate(:user) }
  after_create do |game, _|
    Fabricate(:player, user: game.owner, game: game)
  end
end
