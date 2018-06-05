if command.errors.present?
  json.set! :error, command.errors[:allowed].first
else
  json.(command.result, :id, :status)
  json.set! :user do
    json.set! :id, command.result.user.id
    json.set! :username, command.result.user.username
  end
end
