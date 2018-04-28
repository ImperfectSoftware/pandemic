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

ActiveRecord::Schema.define(version: 20180428162819) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "special_cards", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
