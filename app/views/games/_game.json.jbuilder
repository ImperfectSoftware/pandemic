json.(game, :id, :owner_id, :started)
json.participants game.participants do |participant|
  json.(participant, :user_id, :username, :invitation_id, :accepted)
end
