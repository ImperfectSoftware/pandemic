json.(invitation, :id, :status)
json.set! :user do
  json.set! :id, invitation.user.id
  json.set! :username, invitation.user.username
end
