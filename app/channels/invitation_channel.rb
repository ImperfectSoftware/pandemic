class InvitationChannel < ApplicationCable::Channel
  def subscribed
    # Broadcast only to the authorized user
    if current_user.id == params[:id].to_i
      stream_from("invitation_channel:#{params[:id]}")
    end
  end
end
