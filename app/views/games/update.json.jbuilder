json.(StartedGameDecorator.new(command.result), :id)
json.players command.result.players.order(:created_at).each_with_index.to_a,
  partial: 'players/player', as: :pair
