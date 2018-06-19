json.(StartedGameDecorator.new(game), :id, :active)
json.players game.players.order(:created_at).each_with_index.to_a,
  partial: 'players/player', as: :pair