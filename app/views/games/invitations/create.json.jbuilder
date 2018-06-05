if command.errors.present?
  json.set! :error, command.errors[:allowed].first
else
  json.partial! 'games/invitations/invitation',
    locals: { invitation: command.result }
end
