require 'rails_helper'

RSpec.describe GamesController, type: :request do
  include AuthHelper
  let! (:current_user) { Fabricate(:user, password: '12341234') }

  describe "create game" do
    it "creates a game with started set to false" do
      post "/games", params: {}, headers: headers
      expect(JSON.parse(response.body)["id"]).to eq(Game.last.id)
    end
  end
end
