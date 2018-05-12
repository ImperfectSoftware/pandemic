class InvitationsController < ApplicationController

  def create
    render json: { error: error_message } and return if error_message

    render json: game.invitations.create!(user: user, accepted: false)
  end

  private

  def game
    @game ||= current_user.games.find_by(id: params[:game_id])
  end

  def user
    @user ||= User.find_by(username: params[:username])
  end

  def error_message
    return I18n.t("invitations.user_not_found") if !user
    return I18n.t("invitations.user_invited") if user_invited?
  end

  def user_invited?
    @user_invited ||= game.invitations.find_by(user: user).present?
  end

end
