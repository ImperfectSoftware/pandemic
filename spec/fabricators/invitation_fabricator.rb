Fabricator(:invitation) do
  status { 'inactive' }
end

Fabricator(:accepted_invitation, class_name: Invitation) do
  status { 'accepted' }
  after_create do |invitation, _|
    Fabricate(:player, user: invitation.user, game: invitation.game)
  end
end
