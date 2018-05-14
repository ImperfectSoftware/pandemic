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

    context "with valid params" do
      before(:each) do
        @player_one = game.players.find_by(user: @current_user)
        @player_two = Fabricate(:player, game: game)
      end

      it "assigns cards to players" do
        put "/games/#{game.id}", params: {
          nr_of_epidemic_cards: 4
        }.to_json, headers: headers
        expect(@player_one.reload.cards_composite_ids.present?).to be(true)
        expect(@player_two.reload.cards_composite_ids.present?).to be(true)
      end


      it "sets game player turns" do
        put "/games/#{game.id}", params: {
          nr_of_epidemic_cards: 4
        }.to_json, headers: headers
        expect(game.reload.player_turn_ids.present?).to be(true)
      end

      it "sets game started to true" do
        put "/games/#{game.id}", params: {
          nr_of_epidemic_cards: 4
        }.to_json, headers: headers
        expect(game.reload.started?).to be(true)
      end
    end
  end

end
