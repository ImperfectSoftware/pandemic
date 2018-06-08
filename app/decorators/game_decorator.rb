class GameDecorator < SimpleDelegator
  def started
    started?
  end

  def participants
    @participants ||= participants_from_invitations +
      Array(Participant.fromOwner(owner))
  end

  def created_date
    created_at.to_date.to_formatted_s(:rfc822)
  end

  private

  def participants_from_invitations
    invitations.not_declined.map do |invitation|
      Participant.fromInvitation(invitation)
    end
  end
end
