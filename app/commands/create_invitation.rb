class CreateInvitation
  prepend SimpleCommand

  def initialize(game:, username:)
    @game = game
    @username = username
  end

  def call
    if !user
      errors.add(:allowed, I18n.t("invitations.user_not_found"))
      return
    end
    if user_invited?
      errors.add(:allowed, I18n.t("invitations.user_invited"))
      return
    end
    if maximum_nr_sent?
      errors.add(:allowed, I18n.t("invitations.maximum_number_sent"))
      return
    end
    invitation = @game.invitations.create!(user: user, accepted: false)
    send_broadcast_to_user(invitation)
    invitation
  end

  private

  def user
    @user ||= User.find_by(username: @username)
  end

  def user_invited?
    @game.invitations.find_by(user: user).present?
  end

  def maximum_nr_sent?
    @game.invitations.count == 3
  end

  def send_broadcast_to_user(invitation)
    ActionCable.server.broadcast(
      "invitation_channel:#{user.id}",
      id: invitation.id,
      user_id: user.id,
      game_id: @game.id,
      accepted: false,
      owner_username: @game.owner.username
    )
  end
end
