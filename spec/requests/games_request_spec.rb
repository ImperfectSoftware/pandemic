require 'rails_helper'

RSpec.describe GamesController, type: :request do
  let! (:user) do
    User.create(
      password: '12341234',
      email: 'test@test.com',
      username: 'testuser'
    )
  end

  describe "create game" do
    it "creates a game with started set to false" do
      post "/authenticate?email=#{user.email}&password=#{user.password}"
      token = JSON.parse(response.body)['auth_token']
      headers = {
        "ACCEPT" => "application/json",
        "CONTENT-TYPE" => "application/json",
        "AUTHORIZATION" => token
      }

      post "/games.json", params: {}, headers: headers
      expect(JSON.parse(response.body)["id"]).to eq(Game.last.id)
    end
  end
end
