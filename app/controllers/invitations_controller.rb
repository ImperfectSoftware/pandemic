class InvitationsController < ApplicationController
  skip_before_action :authorize_request
  helper_method :command

  def create
    command.call
  end

  def update
    if update_error_message
      render json: { error: update_error_message }
      return
    end

    invitation = current_user.invitations.find_by(id: params[:id])
    invitation.update!(accepted: params[:accepted])
    if invitation.accepted?
      command = GetUniqueRole.new(players: invitation.game.players).call
      invitation.game.players.create(
        user: current_user,
        role: command.result,
        location_staticid: City.find_by_name('Atlanta').staticid
      )
      ActionCable.server.broadcast(
        "game_channel:#{game.id}",
        username: current_user.username,
        accepted: true
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

  def command
    @command ||= CreateInvitation.new(game: game, username: params[:username])
  end

  def update_error_message
    if game.started? && params[:accepted]
      return I18n.t("invitations.game_started")
    end
    if params[:accepted].blank?
      return I18n.t("errors.missing_param")
    end
  end

   def game
     @game ||= Game.find_by(id: params[:game_id])
   end
end
