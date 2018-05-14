class CreateInvitation
  prepend SimpleCommand

  def initialize(game: game, username:)
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

    @game.invitations.create!(user: user, accepted: false)
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
end
