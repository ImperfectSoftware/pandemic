json.set! :id, player.id
json.invitation do
  json.set! :id, player.invitation&.id
  json.set! :accepted, player.invitation&.accepted
end
json.user do
  json.set! :id, player.user.id
  json.set! :username, player.user.username
end
