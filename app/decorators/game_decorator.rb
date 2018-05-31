class GameDecorator < SimpleDelegator
  def started
    started?
  end

  def participants
    @participants ||= participants_from_invitations + owner_participant
  end

  private

  def participants_from_invitations
    invitations.map do |invitation|
      OpenStruct.new(
        user_id: invitation.user.id,
        username: invitation.user.username,
        invitation_id: invitation.id,
        accepted: invitation.accepted
      )
    end
  end

  def owner_participant
    Array(OpenStruct.new(
      user_id: owner_id,
      username: owner.username,
      invitation_id: 0,
      accepted: true
    ))
  end
end
