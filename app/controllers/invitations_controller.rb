class InvitationsController < ApplicationController
  skip_before_action :authorize_request

  def index
    @invitations = current_user.invitations.order(created_at: :desc)
  end
end
