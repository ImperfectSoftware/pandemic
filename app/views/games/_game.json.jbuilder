json.(game, :id, :owner_id, :started, :created_date, :name)
json.participants game.participants do |participant|
  json.(participant, :user_id, :username, :invitation_id, :accepted)
end
