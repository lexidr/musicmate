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

ActiveRecord::Schema[8.1].define(version: 2026_09_29_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "music_profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status", default: "empty", null: false
    t.integer "tracks_count", default: 0, null: false
    t.integer "artists_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_music_profiles_on_user_id", unique: true
  end

  create_table "profile_items", force: :cascade do |t|
    t.bigint "music_profile_id", null: false
    t.string "item_type", null: false
    t.string "name", null: false
    t.string "artist_name"
    t.string "spotify_id", null: false
    t.string "spotify_url"
    t.string "image_url"
    t.integer "weight", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["music_profile_id", "item_type"], name: "index_profile_items_on_music_profile_id_and_item_type"
    t.index ["music_profile_id"], name: "index_profile_items_on_music_profile_id"
  end

  create_table "spotify_connections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "access_token", null: false
    t.text "refresh_token"
    t.datetime "token_expires_at"
    t.string "scopes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_spotify_connections_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "spotify_user_id", null: false
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["spotify_user_id"], name: "index_users_on_spotify_user_id", unique: true
  end

  add_foreign_key "music_profiles", "users"
  add_foreign_key "profile_items", "music_profiles"
  add_foreign_key "spotify_connections", "users"
end
