# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180428222821) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.integer "color"
    t.integer "player_id"
    t.integer "game_id"
    t.boolean "research_station"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "staticid"
    t.index ["game_id"], name: "index_cities_on_game_id"
    t.index ["player_id"], name: "index_cities_on_player_id"
  end

  create_table "cure_markers", force: :cascade do |t|
    t.integer "color"
    t.boolean "eradicated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.boolean "started"
    t.integer "current_player_id"
    t.integer "player_turn_ids", array: true
    t.integer "used_infection_card_city_ids", array: true
    t.integer "unused_infection_card_city_ids", array: true
    t.integer "nr_of_epidemic_cards"
    t.integer "discarded_special_player_card_ids", array: true
    t.string "unused_player_card_ids", array: true
    t.integer "number_of_outbreaks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "infections", force: :cascade do |t|
    t.integer "city_id"
    t.integer "color"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_infections_on_city_id"
  end

  create_table "movements", force: :cascade do |t|
    t.integer "from_city_id"
    t.integer "to_city_id"
    t.integer "player_id"
    t.boolean "by_dispatcher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.integer "user_id"
    t.string "role"
    t.integer "current_location_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_location_id"], name: "index_players_on_current_location_id"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
