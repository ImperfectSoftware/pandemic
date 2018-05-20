class InvitationsController < ApplicationController

  def create
    command = CreateInvitation.new(game: game, username: params[:username])
    command.call

    if command.errors.present?
      render json: { error: command.errors[:allowed].first }
    else
      render json: command.result
    end
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
        current_location_staticid: City.find_by_name('Atlanta').staticid
      )
    end
    render json: invitation
  end

  def destroy
    if game.started?
      render json: { error: I18n.t("invitations.game_started") }
      return
    end

    invitation = current_user.invitations.find_by(id: params[:id])
    player = current_user.players.find_by(game: invitation.game)
    invitation.destroy
    player.destroy
  end

  private

  def game
    @game ||= Game.find_by(id: params[:game_id])
  end

  def update_error_message
    if game.started? && params[:accepted]
      return I18n.t("invitations.game_started")
    end
    if params[:accepted].blank?
      return I18n.t("errors.missing_param")
    end
  end
end
