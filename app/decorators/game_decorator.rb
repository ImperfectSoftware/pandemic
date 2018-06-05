class GameDecorator < SimpleDelegator
  def started
    started?
  end

  def participants
    @participants ||= participants_from_invitations + owner_participant
  end

  def created_date
    created_at.to_date.to_formatted_s(:rfc822)
  end

  private

  def participants_from_invitations
    invitations.map do |invitation|
      OpenStruct.new(
        user_id: invitation.user.id,
        username: invitation.user.username,
        invitation_id: invitation.id,
        status: invitation.status
      )
    end
  end

  def owner_participant
    Array(OpenStruct.new(
      user_id: owner_id,
      username: owner.username,
      invitation_id: 0,
      status: Invitation.statuses.keys.second
    ))
  end
end
