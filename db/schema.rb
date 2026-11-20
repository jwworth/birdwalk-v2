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

ActiveRecord::Schema[8.1].define(version: 2026_11_20_182423) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "photos", force: :cascade do |t|
    t.bigint "bird_id", null: false
    t.string "source_url", null: false
    t.string "creator", null: false
    t.string "license_name", null: false
    t.string "license_url", null: false
    t.text "attribution_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bird_id"], name: "index_photos_on_bird_id"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "challenges", "locations"
  add_foreign_key "photos", "birds"
  add_foreign_key "rounds", "birds", column: "correct_bird_id"
  add_foreign_key "rounds", "birds", column: "first_distractor_id"
  add_foreign_key "rounds", "birds", column: "second_distractor_id"
  add_foreign_key "rounds", "birds", column: "third_distractor_id"
  add_foreign_key "rounds", "challenges"
end
