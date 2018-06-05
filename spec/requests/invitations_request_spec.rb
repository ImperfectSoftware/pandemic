require 'rails_helper'

RSpec.describe InvitationsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  attr_reader :game
  before(:context) do
    @user = Fabricate(:user)
    @current_user = Fabricate(:user, password: '12341234')
    @game = Fabricate(:game, owner: current_user, status: 'not_started')
  end

  before(:each) do
    Fabricate(:invitation, game: game, user: current_user, status: 'accepted')
    Fabricate(:invitation, game: game, user: current_user, status: 'declined')
    Fabricate(:invitation, game: game, user: current_user, status: 'inactive')
  end

  it "displays accepted invitation" do
    get "/invitations", headers: headers
    invitations_count = body['invitations'].select do |invite|
      invite['status'] == 'accepted'
    end.count
    expect(invitations_count).to eq(1)
  end

  it "displays declined invitation" do
    get "/invitations", headers: headers
    invitations_count = body['invitations'].select do |invite|
      invite['status'] == 'declined'
    end.count
    expect(invitations_count).to eq(1)
  end

  it "displays inactive invitation" do
    get "/invitations", headers: headers
    invitations_count = body['invitations'].select do |invite|
      invite['status'] == 'inactive'
    end.count
    expect(invitations_count).to eq(1)
  end
end
