require 'rails_helper'

RSpec.describe InvitationsController, type: :request do
  include AuthHelper
  let! (:current_user) { Fabricate(:user, password: '12341234') }
  let! (:game) { Fabricate(:game, owner: current_user) }
  let (:user) { Fabricate(:user) }

  describe "create game invitation" do
    it "errors out if user is not registered" do
      post "/games/10/invitations.json", params: {
        username: "unregistered user"
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t("invitations.user_not_found"))
    end

    it "creates an invite for a game" do
      post "/games/#{game.id}/invitations.json", params: {
        username: user.username
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["id"])
        .to eq(Invitation.last.id)
    end

    it "errors out if attempting to create a second invite for the same user" do
      post "/games/#{game.id}/invitations.json", params: {
        username: user.username
      }.to_json, headers: headers
      post "/games/#{game.id}/invitations.json", params: {
        username: user.username
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t("invitations.user_invited"))
    end
  end
end
