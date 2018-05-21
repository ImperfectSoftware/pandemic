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

ActiveRecord::Schema.define(version: 20180520235900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cure_markers", force: :cascade do |t|
    t.integer "color"
    t.boolean "eradicated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
    t.boolean "cured"
    t.index ["game_id"], name: "index_cure_markers_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.boolean "started"
    t.integer "player_turn_ids", array: true
    t.integer "nr_of_epidemic_cards"
    t.integer "discarded_special_player_card_ids", array: true
    t.string "unused_player_card_ids", array: true
    t.integer "number_of_outbreaks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner_id"
    t.string "used_infection_card_city_staticids", array: true
    t.string "unused_infection_card_city_staticids", array: true
    t.integer "turn_nr"
    t.integer "actions_taken"
  end

  create_table "infections", force: :cascade do |t|
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "city_staticid"
    t.integer "game_id"
    t.string "color"
    t.index ["game_id"], name: "index_infections_on_game_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "game_id"
    t.integer "user_id"
    t.boolean "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_invitations_on_game_id"
    t.index ["user_id"], name: "index_invitations_on_user_id"
  end

  create_table "movement_proposals", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "player_id"
    t.string "city_staticid"
    t.integer "turn_nr"
    t.integer "game_id"
    t.boolean "accepted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_movement_proposals_on_creator_id"
    t.index ["game_id"], name: "index_movement_proposals_on_game_id"
    t.index ["player_id"], name: "index_movement_proposals_on_player_id"
  end

  create_table "movements", force: :cascade do |t|
    t.integer "player_id"
    t.boolean "by_dispatcher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "from_city_staticid"
    t.string "to_city_staticid"
  end

  create_table "operations_expert_actions", force: :cascade do |t|
    t.integer "turn_nr"
    t.integer "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_operations_expert_actions_on_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "location_staticid"
    t.string "cards_composite_ids", array: true
    t.integer "role"
    t.index ["game_id"], name: "index_players_on_game_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "research_stations", force: :cascade do |t|
    t.integer "game_id"
    t.string "city_staticid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "share_cards", force: :cascade do |t|
    t.integer "from_player_id"
    t.integer "to_player_id"
    t.boolean "accepted"
    t.string "city_staticid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "creator_id"
    t.index ["creator_id"], name: "index_share_cards_on_creator_id"
    t.index ["from_player_id"], name: "index_share_cards_on_from_player_id"
    t.index ["to_player_id"], name: "index_share_cards_on_to_player_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
