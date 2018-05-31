json.(game, :id, :owner_id)
json.set! :started, game.started?
json.players game.players, partial: 'players/player', as: :player
