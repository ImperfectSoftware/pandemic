Fabricator(:game) do
  turn_nr { 1 }
  actions_taken { 0 }
  status { 'not_started' }
  owner { Fabricate(:user) }
  after_create do |game, _|
    Fabricate(:player, user: game.owner, game: game)
  end
end
