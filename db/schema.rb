# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_20_181020) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "birds", force: :cascade do |t|
    t.string "common_name", null: false
    t.string "scientific_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((common_name)::text)", name: "index_birds_on_lower_common_name", unique: true
    t.index "lower((scientific_name)::text)", name: "index_birds_on_lower_scientific_name", unique: true
  end

  create_table "challenges", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.integer "rotation_position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_challenges_on_location_id", unique: true
    t.index ["rotation_position"], name: "index_challenges_on_rotation_position", unique: true
    t.check_constraint "rotation_position > 0", name: "challenges_rotation_position_positive"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text), state", name: "index_locations_on_lower_name_and_state", unique: true
  end

  create_table "rounds", force: :cascade do |t|
    t.bigint "challenge_id", null: false
    t.integer "position", null: false
    t.bigint "correct_bird_id"
    t.bigint "first_distractor_id"
    t.bigint "second_distractor_id"
    t.bigint "third_distractor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_id", "position"], name: "index_rounds_on_challenge_id_and_position", unique: true
    t.index ["challenge_id"], name: "index_rounds_on_challenge_id"
    t.index ["correct_bird_id"], name: "index_rounds_on_correct_bird_id"
    t.index ["first_distractor_id"], name: "index_rounds_on_first_distractor_id"
    t.index ["second_distractor_id"], name: "index_rounds_on_second_distractor_id"
    t.index ["third_distractor_id"], name: "index_rounds_on_third_distractor_id"
    t.check_constraint "\"position\" >= 1 AND \"position\" <= 5", name: "rounds_position_range"
    t.check_constraint "correct_bird_id <> first_distractor_id AND correct_bird_id <> second_distractor_id AND correct_bird_id <> third_distractor_id AND first_distractor_id <> second_distractor_id AND first_distractor_id <> third_distractor_id AND second_distractor_id <> third_distractor_id", name: "rounds_distinct_birds"
  end

  add_foreign_key "challenges", "locations"
  add_foreign_key "rounds", "birds", column: "correct_bird_id"
  add_foreign_key "rounds", "birds", column: "first_distractor_id"
  add_foreign_key "rounds", "birds", column: "second_distractor_id"
  add_foreign_key "rounds", "birds", column: "third_distractor_id"
  add_foreign_key "rounds", "challenges"
end
