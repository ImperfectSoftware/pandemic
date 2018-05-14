require 'rails_helper'

RSpec.describe GamesController, type: :request do
  include AuthHelper
  before(:context) do
    @current_user = Fabricate(:user, password: '12341234')
  end

  describe "create game" do
    it "creates a game with started set to false" do
      post "/games", params: {}, headers: headers
      expect(JSON.parse(response.body)["id"]).to eq(Game.last.id)
    end

    it "sets game owner's player current location to Atlanta" do
      post "/games", params: {}, headers: headers
      current_location_name = @current_user.players.find_by(game: Game.last)
        .current_location.name
      expect(current_location_name).to eq('Atlanta')
    end

    it "assigns game role to player" do
      post "/games", params: {}, headers: headers
      player_role = Game.last.players.first.role
      expect(Role.all.map(&:name).include?(player_role)).to be(true)
    end
  end

  describe "update game" do
    let(:game) { Fabricate(:game, owner: @current_user) }

    it "does not start a game with only one player" do
      put "/games/#{game.id}", params: {
        nr_of_epidemic_cards: 4
      }.to_json, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t("games.minimum_number_of_players"))
    end

    it "errors out if number of epidemic cards is not provided" do
      player_two = Fabricate(:player, game: game)
      put "/games/#{game.id}", params: {}, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t("games.incorrect_nr_of_epidemic_cards"))
    end

    it "errors out if game has already started" do
      game.update!(started: true)
      put "/games/#{game.id}", params: {}, headers: headers
      expect(JSON.parse(response.body)["error"])
        .to eq(I18n.t("games.already_started"))
    end
  end

end
