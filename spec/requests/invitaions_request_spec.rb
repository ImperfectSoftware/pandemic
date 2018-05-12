require 'rails_helper'

RSpec.describe InvitationsController, type: :request do
  include AuthHelper

  before(:context) do
    @user = Fabricate(:user)
    @current_user = Fabricate(:user, password: '12341234')
    @game = Fabricate(:game, owner: current_user)
  end

  describe "create game invitation" do
    it "errors out if user is not registered" do
      post "/games/10/invitations", params: {
        username: "unregistered user"
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t("invitations.user_not_found"))
    end

    it "creates an invite for a game" do
      post "/games/#{@game.id}/invitations", params: {
        username: @user.username
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["id"])
        .to eq(Invitation.last.id)
    end

    it "errors out if attempting to create a second invite for the same user" do
      post "/games/#{@game.id}/invitations", params: {
        username: @user.username
      }.to_json, headers: headers
      post "/games/#{@game.id}/invitations", params: {
        username: @user.username
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t("invitations.user_invited"))
    end
  end

  describe "update game invitation" do
    before(:all) do
      change_logged_in_user(@user)
    end
    let (:invitation) { Fabricate(:invitation, game: @game, user: @user) }

    context "before game started" do
      it 'accepts invitation' do
        put "/games/#{@game.id}/invitations/#{invitation.id}", params: {
          accepted: true
        }.to_json, headers: headers
        expect(Invitation.last.accepted?).to be(true)
      end

      it 'creates player on invitation acceptance' do
        put "/games/#{@game.id}/invitations/#{invitation.id}", params: {
          accepted: true
        }.to_json, headers: headers
        expect(@user.players.find_by(game: @game)).to be
      end

      it 'declines invitation' do
        put "/games/#{@game.id}/invitations/#{invitation.id}", params: {
          accepted: false
        }.to_json, headers: headers
        expect(Invitation.last.accepted?).to be(false)
      end

      it 'does not create player when invitation is declined' do
        put "/games/#{@game.id}/invitations/#{invitation.id}", params: {
          accepted: false
        }.to_json, headers: headers
        expect(@user.players.find_by(game: @game)).to be_nil
      end
    end

    context "after game started" do
      before(:context) do
        @game.update!(started: true)
      end
      it 'errors out on invitation acceptance' do
        put "/games/#{@game.id}/invitations/#{invitation.id}", params: {
          accepted: true
        }.to_json, headers: headers
        expect(JSON.parse(response.body)["error"])
          .to eq(I18n.t("invitations.game_started"))
      end

      it 'does not create a player on invitation acceptance' do
        put "/games/#{@game.id}/invitations/#{invitation.id}", params: {
          accepted: true
        }.to_json, headers: headers
        expect(@user.players.find_by(game: @game)).to be_nil
      end

      it 'declines invitation' do
        put "/games/#{@game.id}/invitations/#{invitation.id}", params: {
          accepted: false
        }.to_json, headers: headers
        expect(Invitation.last.accepted?).to be(false)
      end

      it 'does not create player when invitation is declined' do
        put "/games/#{@game.id}/invitations/#{invitation.id}", params: {
          accepted: false
        }.to_json, headers: headers
        expect(@user.players.find_by(game: @game)).to be_nil
      end
    end

    context "withouth accepted params" do
      it 'returns error message' do
        put "/games/#{@game.id}/invitations/#{invitation.id}",
          params: {}.to_json, headers: headers
        expect(JSON.parse(response.body)["error"])
          .to eq(I18n.t("invitations.errors.missing_param"))
      end
    end
  end
end
