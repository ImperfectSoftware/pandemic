require 'rails_helper'

RSpec.describe GamesController, type: :request do
  include AuthHelper
  include ResponseHelpers

  before(:context) do
    @current_user = Fabricate(:user, password: '12341234')
  end

  describe "create game" do
    it "creates a game with started set to false" do
      post "/games", params: {}, headers: headers
      expect(body["id"]).to eq(Game.last.id)
      expect(Game.last.started?).to be(false)
    end

    it "creates a game with turn_nr set to 1" do
      post "/games", params: {}, headers: headers
      expect(body["id"]).to eq(Game.last.id)
      expect(Game.last.turn_nr).to eq(1)
    end

    it "creates a game with actions_taken set to 0" do
      post "/games", params: {}, headers: headers
      expect(body["id"]).to eq(Game.last.id)
      expect(Game.last.actions_taken).to eq(0)
    end

    it "sets game owner's player current location to Atlanta" do
      post "/games", params: {}, headers: headers
      location = @current_user.players.find_by(game: Game.last).location
      expect(location.name).to eq('Atlanta')
    end

    it "assigns game role to player" do
      post "/games", params: {}, headers: headers
      player_role = Game.last.players.first.role
      expect(Player.roles.keys.include?(player_role)).to be(true)
    end
  end

  describe "update game" do
    let(:game) { Fabricate(:game, owner: @current_user) }

    it "does not start a game with only one player" do
      put "/games/#{game.id}", params: {
        nr_of_epidemic_cards: 4
      }.to_json, headers: headers
      expect(error).to eq(I18n.t("games.minimum_number_of_players"))
    end

    it "errors out if number of epidemic cards is not provided" do
      player_two = Fabricate(:player, game: game)
      put "/games/#{game.id}", params: {}, headers: headers
      expect(error).to eq(I18n.t("games.incorrect_nr_of_epidemic_cards"))
    end

    it "errors out if game has already started" do
      game.started!
      put "/games/#{game.id}", params: {}, headers: headers
      expect(error).to eq(I18n.t("games.already_started"))
    end

    context "with valid params" do
      before(:all) do
        @game = Fabricate(:game, owner: @current_user)
        @player_one = @game.players.find_by(user: @current_user)
        @player_two = Fabricate(:player, game: @game)
        put "/games/#{@game.id}", params: {
          nr_of_epidemic_cards: 4
        }.to_json, headers: headers
      end

      it "assigns cards to players" do
        expect(@player_one.reload.cards_composite_ids.present?).to be(true)
        expect(@player_two.reload.cards_composite_ids.present?).to be(true)
      end

      it "sets game player turns" do
        expect(@game.reload.player_turn_ids.present?).to be(true)
      end

      it "sets game started to true" do
        expect(@game.reload.started?).to be(true)
      end

      it "creates start game infections" do
        expect(@game.infections.where(quantity: 3).count).to eq(3)
        expect(@game.infections.where(quantity: 2).count).to eq(3)
        expect(@game.infections.where(quantity: 1).count).to eq(3)
      end

      it "stores used_infection_card_city_staticids" do
        expect(@game.reload.used_infection_card_city_staticids.count).to eq(9)
      end

      it "stores unused_infection_card_city_staticids" do
        expect(@game.reload.unused_infection_card_city_staticids.count).to eq(39)
      end

      it "returns a game object on update" do
        expect(body["id"]).to eq(@game.id)
      end
    end
  end
end
