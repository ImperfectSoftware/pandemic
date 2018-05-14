Fabricator(:invitation) do
end

Fabricator(:accepted_invitation, class_name: Invitation) do
  accepted { true }
  after_create do |invitation, _|
    Fabricate(:player, user: invitation.user, game: invitation.game)
  end
end
