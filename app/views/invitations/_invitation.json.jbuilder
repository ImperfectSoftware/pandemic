json.(invitation, :id, :status)
json.user { json.(invitation.user, :id, :username) }
json.game do
  json.(invitation.game, :id, :name)
  json.owner_username invitation.game.owner.username
end
