Fabricator(:game) do
  turn_nr { 1 }
  actions_taken { 0 }
  status { 'started' }
  owner { Fabricate(:user) }
  after_create do |game, _|
    player = Fabricate(:player, user: game.owner, game: game)
    game.update!(player_turn_ids: [player.id])
    CureMarker.colors.keys.each do |color|
      game.cure_markers.create!(color: color, cured: false, eradicated: false)
    end
  end
end

Fabricator(:game_between_infect_and_intensify, class_name: Game) do
  turn_nr { 1 }
  actions_taken { 0 }
  status { 'not_started' }
  owner { Fabricate(:user) }
  nr_of_intensified_cards { 5 }
  unused_infection_card_city_staticids { %w{0 1 2 3 4} }
  after_create do |game, _|
    player = Fabricate(:player, user: game.owner, game: game)
    game.update!(player_turn_ids: [player.id])
  end
end

Fabricator(:two_player_game, class_name: Game) do
  turn_nr { 1 }
  actions_taken { 0 }
  status { 'started' }
  owner { Fabricate(:user) }
  nr_of_intensified_cards { 5 }
  unused_infection_card_city_staticids { %w{0 1 2 3 4} }
  after_create do |game, _|
    player = Fabricate(:player, user: game.owner, game: game)
    playerTwo = Fabricate(:player, game: game)
    game.update!(player_turn_ids: [player.id, playerTwo.id])
  end
end
