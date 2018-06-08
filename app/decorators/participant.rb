class Participant
  def self.fromInvitation(invitation)
    OpenStruct.new(
      user_id: invitation.user.id,
      username: invitation.user.username,
      invitation_id: invitation.id,
      status: invitation.status
    )
  end

  def self.fromOwner(owner)
    OpenStruct.new(
      user_id: owner.id,
      username: owner.username,
      invitation_id: 0,
      status: Invitation.statuses.keys.second
    )
  end
end
