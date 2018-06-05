require 'rails_helper'

RSpec.describe Games::InvitationsController, type: :request do
  include AuthHelper
  include ResponseHelpers

  before(:context) do
    @user = Fabricate(:user)
    @current_user = Fabricate(:user, password: '12341234')
    @game = Fabricate(:game, owner: current_user, status: 'not_started')
  end

  describe "create game invitation" do
    it "errors out if user is not registered" do
      post "/games/10/invitations", params: {
        username: "unregistered user"
      }.to_json, headers: headers
      expect(error).to eq(I18n.t("invitations.user_not_found"))
    end

    describe "returned data" do
      before(:each) do
        post "/games/#{@game.id}/invitations", params: {
          username: @user.username
        }.to_json, headers: headers
      end

      it "displays invite id" do
        expect(body["id"]).to eq(Invitation.last.id)
      end

      it "displays invite status" do
        expect(body["status"]).to eq(Invitation.statuses.keys.last)
      end

      it "displays invite user's username" do
        expect(body["user"]["username"]).to eq(@user.username)
      end

      it "displays invite user's id" do
        expect(body["user"]["id"]).to eq(@user.id)
      end
    end

    it "errors out if attempting to create a second invite for the same user" do
      post "/games/#{@game.id}/invitations", params: {
        username: @user.username
      }.to_json, headers: headers
      post "/games/#{@game.id}/invitations", params: {
        username: @user.username
      }.to_json, headers: headers
      expect(error).to eq(I18n.t("invitations.user_invited"))
    end

    it "errors out if 3 game invitations already exist" do
      user_three = Fabricate(:user)
      user_four = Fabricate(:user)
      user_five = Fabricate(:user)
      post "/games/#{@game.id}/invitations", params: {
        username: @user.username
      }.to_json, headers: headers
      post "/games/#{@game.id}/invitations", params: {
        username: user_three.username
      }.to_json, headers: headers
      post "/games/#{@game.id}/invitations", params: {
        username: user_four.username
      }.to_json, headers: headers
      post "/games/#{@game.id}/invitations", params: {
        username: user_five.username
      }.to_json, headers: headers
      expect(error).to eq(I18n.t("invitations.maximum_number_sent"))
    end
  end

  describe "update game invitation" do
    attr_reader :invitation

    before(:all) do
      change_logged_in_user(@user)
      @invitation = Fabricate(:invitation, game: @game, user: @user)
    end

    context "before game started" do
      it 'accepts invitation' do
        put "/games/#{@game.id}/invitations", params: {
          status: 'accepted'
        }.to_json, headers: headers
        expect(Invitation.last.accepted?).to be(true)
      end

      it 'creates player on invitation acceptance' do
        put "/games/#{@game.id}/invitations", params: {
          status: 'accepted'
        }.to_json, headers: headers
        expect(@user.players.find_by(game: @game)).to be
      end

      it "sets player's current location on invitation acceptance to Atlanta" do
        put "/games/#{@game.id}/invitations", params: {
          status: 'accepted'
        }.to_json, headers: headers
        location = @current_user.players.find_by(game: @game).location
        expect(location.name).to eq('Atlanta')
      end

      it "sets player's role to a role not yet taken" do
        put "/games/#{@game.id}/invitations", params: {
          status: 'accepted'
        }.to_json, headers: headers
        player_one = @game.players.find_by(user: @game.owner)
        player_two = @game.players.find_by(user: @user)
        expect(player_two.role).to_not be_nil
        expect(player_one.role).to_not eq(player_two.role)
      end

      it 'declines invitation' do
        put "/games/#{@game.id}/invitations", params: {
          status: 'declined'
        }.to_json, headers: headers
        expect(Invitation.last.declined?).to be(true)
      end

      it 'does not create player when invitation is declined' do
        put "/games/#{@game.id}/invitations", params: {
          status: 'declined'
        }.to_json, headers: headers
        expect(@user.players.find_by(game: @game)).to be_nil
      end
    end

    context "after game started" do
      before(:context) do
        @game.started!
      end
      it 'errors out on invitation acceptance' do
        put "/games/#{@game.id}/invitations", params: {
          status: 'accepted'
        }.to_json, headers: headers
        expect(error).to eq(I18n.t("invitations.game_started"))
      end

      it 'does not create a player on invitation acceptance' do
        put "/games/#{@game.id}/invitations", params: {
          status: 'accepted'
        }.to_json, headers: headers
        expect(@user.players.find_by(game: @game)).to be_nil
      end

      it 'declines invitation' do
        put "/games/#{@game.id}/invitations", params: {
          status: 'declined'
        }.to_json, headers: headers
        expect(Invitation.last.declined?).to be(true)
      end

      it 'does not create player when invitation is declined' do
        put "/games/#{@game.id}/invitations", params: {
          status: 'declined'
        }.to_json, headers: headers
        expect(@user.players.find_by(game: @game)).to be_nil
      end
    end

    context "withouth accepted params" do
      it 'returns error message' do
        put "/games/#{@game.id}/invitations",
          params: {}.to_json, headers: headers
        expect(error).to eq(I18n.t("errors.missing_param"))
      end
    end
  end

  describe "delete game invitation" do
    context "after game started" do
      it "should not be allowed to delete if game started" do
        change_logged_in_user(@user)
        invitation = Fabricate(:accepted_invitation, game: @game, user: @user)
        delete "/games/#{@game.id}/invitations",
          params: {}, headers: headers
        expect(error).to eq(I18n.t("invitations.game_started"))
      end
    end

    context "before game started" do
      it "should delete associated player when deleting an invitation" do
        @game.not_started!
        change_logged_in_user(@user)
        invitation = Fabricate(:accepted_invitation, game: @game, user: @user)
        delete "/games/#{@game.id}/invitations",
          params: {}, headers: headers
        expect(@game.players.count).to eq(1)
      end
    end
  end
end
