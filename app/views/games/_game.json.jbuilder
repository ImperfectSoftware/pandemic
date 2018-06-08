json.(game, :id, :owner_id, :started, :created_date, :name)
json.participants game.participants, partial: 'games/participant',
  as: :participant
