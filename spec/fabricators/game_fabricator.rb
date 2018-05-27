Fabricator(:game) do
  turn_nr { 1 }
  actions_taken { 0 }
  status { 'started' }
  owner { Fabricate(:user) }
  after_create do |game, _|
    player = Fabricate(:player, user: game.owner, game: game)
  end
end

Fabricator(:game_between_epidemic_stages, class_name: Game) do
  turn_nr { 1 }
  actions_taken { 0 }
  status { 'not_started' }
  owner { Fabricate(:user) }
  nr_of_intensified_cards { 5 }
  unused_infection_card_city_staticids { %w{0 1 2 3 4} }
  after_create do |game, _|
    Fabricate(:player, user: game.owner, game: game)
  end
end
