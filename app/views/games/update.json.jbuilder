json.(StartedGameDecorator.new(command.result), :id)
json.players command.result.players.each_with_index.to_a,
  partial: 'players/player', as: :pair
