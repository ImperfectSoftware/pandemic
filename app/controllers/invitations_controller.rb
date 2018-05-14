class InvitationsController < ApplicationController

  def create
    if create_error_message
      render json: { error: create_error_message }
      return
    end

    game = current_user.games.find_by(id: params[:game_id])
    render json: game.invitations.create!(user: user, accepted: false)
  end

  def update
    if update_error_message
      render json: { error: update_error_message }
      return
    end

    invitation = current_user.invitations.find_by(id: params[:id])
    invitation.update(accepted: params[:accepted])
    if invitation.accepted?
      role = GetUniqueRole.new(players: invitation.game.players).call
      invitation.game.players.create(
        user: current_user,
        role: role,
        current_location_staticid: GraphCity.find_by_name('Atlanta').staticid
      )
    end
    render json: invitation
  end

  private

  def game
    @game ||= Game.find_by(id: params[:game_id])
  end

  def user
    @user ||= User.find_by(username: params[:username])
  end

  def create_error_message
    return I18n.t("invitations.user_not_found") if !user
    return I18n.t("invitations.user_invited") if user_invited?
  end

  def update_error_message
    if game.started? && params[:accepted]
      return I18n.t("invitations.game_started")
    end
    if params[:accepted].blank?
      return I18n.t("invitations.errors.missing_param")
    end
  end

  def user_invited?
    @user_invited ||= game.invitations.find_by(user: user).present?
  end

end
