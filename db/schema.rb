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

ActiveRecord::Schema.define(version: 2021_04_21_170132) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ahoy_events", force: :cascade do |t|
    t.bigint "visit_id"
    t.bigint "user_id"
    t.string "name"
    t.text "properties"
    t.datetime "time"
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token"
    t.string "visitor_token"
    t.bigint "user_id"
    t.string "ip"
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain"
    t.text "landing_page"
    t.string "browser"
    t.string "os"
    t.string "device_type"
    t.string "country"
    t.string "region"
    t.string "city"
    t.string "utm_source"
    t.string "utm_medium"
    t.string "utm_term"
    t.string "utm_content"
    t.string "utm_campaign"
    t.datetime "started_at"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
  end

  create_table "article_pictures", force: :cascade do |t|
    t.string "picture"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "width"
    t.integer "height"
  end

  create_table "article_taggings", force: :cascade do |t|
    t.bigint "article_tag_id"
    t.bigint "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_article_taggings_on_article_id"
    t.index ["article_tag_id"], name: "index_article_taggings_on_article_tag_id"
  end

  create_table "article_tags", force: :cascade do |t|
    t.text "name"
    t.text "context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "bookmarks_count", default: 0
  end

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_pages"
    t.bigint "reply_to_id"
    t.integer "reply_number", default: 0
    t.integer "kudos_count", default: 0
    t.integer "signal_boosts_count", default: 0
    t.integer "planned_pages", default: 1
    t.integer "bookmarks_count", default: 0
    t.integer "impressions_count", default: 0
    t.text "display_name"
    t.text "editing_password_digest"
    t.text "display_image"
    t.boolean "anonymous", default: false
    t.integer "pages_count", default: 0
    t.bigint "thread_id"
    t.datetime "reply_time"
    t.index ["reply_to_id"], name: "index_articles_on_reply_to_id"
    t.index ["thread_id"], name: "index_articles_on_thread_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id"
    t.string "bookmarkable_type"
    t.bigint "bookmarkable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bookmarkable_type", "bookmarkable_id"], name: "index_bookmarks_on_bookmarkable_type_and_bookmarkable_id"
    t.index ["user_id", "bookmarkable_id", "bookmarkable_type"], name: "user_bookmark_index", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "comic_pages", force: :cascade do |t|
    t.bigint "comic_id"
    t.integer "page", default: 1
    t.string "drawing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "width"
    t.integer "height"
    t.index ["comic_id"], name: "index_comic_pages_on_comic_id"
  end

  create_table "comics", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.bigint "user_id"
    t.integer "pages"
    t.integer "rating"
    t.integer "front_page_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "authorship", default: 0
    t.integer "max_pages", default: 1
    t.datetime "page_addition"
    t.integer "kudos_count", default: 0
    t.integer "bookmarks_count", default: 0
    t.index ["user_id"], name: "index_comics_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id"
    t.string "commentable_type"
    t.bigint "commentable_id"
    t.string "work_type"
    t.bigint "work_id"
    t.string "name"
    t.string "email"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
    t.index ["work_type", "work_id"], name: "index_comments_on_work_type_and_work_id"
  end

  create_table "drawings", force: :cascade do |t|
    t.string "title"
    t.text "caption"
    t.bigint "user_id"
    t.string "drawing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rating", default: 0
    t.integer "authorship", default: 0
    t.integer "width"
    t.integer "height"
    t.integer "kudos_count", default: 0
    t.integer "bookmarks_count", default: 0
    t.index ["user_id"], name: "index_drawings_on_user_id"
  end

  create_table "findings", force: :cascade do |t|
    t.text "thing_name"
    t.integer "required_experience"
    t.float "scarcity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gatherings", force: :cascade do |t|
    t.bigint "item_id"
    t.float "delay"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_gatherings_on_item_id"
  end

  create_table "impressions", force: :cascade do |t|
    t.string "impressionable_type"
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name"
    t.string "action_name"
    t.string "view_name"
    t.string "request_hash"
    t.string "ip_address"
    t.string "session_hash"
    t.text "message"
    t.text "referrer"
    t.text "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index"
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index"
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index"
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index"
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index"
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index"
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index"
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index"
    t.index ["user_id"], name: "index_impressions_on_user_id"
  end

  create_table "ingredients", force: :cascade do |t|
    t.bigint "preparation_id"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_ingredients_on_item_id"
    t.index ["preparation_id"], name: "index_ingredients_on_preparation_id"
  end

  create_table "inventory_entries", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "item_id"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_inventory_entries_on_item_id"
    t.index ["user_id"], name: "index_inventory_entries_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kudos", force: :cascade do |t|
    t.bigint "user_id"
    t.string "work_type"
    t.bigint "work_id"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "work_id", "work_type"], name: "user_kudos_index", unique: true
    t.index ["user_id"], name: "index_kudos_on_user_id"
    t.index ["work_type", "work_id"], name: "index_kudos_on_work_type_and_work_id"
  end

  create_table "legacy_users", force: :cascade do |t|
    t.bigint "user_id"
    t.text "legacy_username"
    t.text "legacy_password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_legacy_users_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "article_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "page_number", default: 1
    t.text "title"
    t.text "display_image"
    t.index ["article_id", "page_number"], name: "page_number_index", unique: true
    t.index ["article_id"], name: "index_pages_on_article_id"
  end

  create_table "preparations", force: :cascade do |t|
    t.text "name"
    t.bigint "product_id"
    t.float "time_required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_preparations_on_product_id"
  end

  create_table "series", force: :cascade do |t|
    t.string "title"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["url"], name: "index_series_on_url", unique: true
    t.index ["user_id"], name: "index_series_on_user_id"
  end

  create_table "series_articles", force: :cascade do |t|
    t.bigint "series_id"
    t.bigint "article_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["article_id"], name: "index_series_articles_on_article_id"
    t.index ["series_id"], name: "index_series_articles_on_series_id"
  end

  create_table "shrine_pictures", force: :cascade do |t|
    t.text "picture_data"
    t.string "page_type"
    t.bigint "page_id"
    t.boolean "inline_picture", default: false
    t.index ["page_type", "page_id"], name: "index_shrine_pictures_on_page_type_and_page_id"
  end

  create_table "signal_boosts", force: :cascade do |t|
    t.bigint "origin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.index ["origin_id"], name: "index_signal_boosts_on_origin_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.bigint "user_id"
    t.string "post_type"
    t.bigint "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "timeline_time"
    t.index ["post_type", "post_id"], name: "index_statuses_on_post_type_and_post_id"
    t.index ["user_id"], name: "index_statuses_on_user_id"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "activity_type"
    t.text "details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_user_activities_on_user_id"
  end

  create_table "user_languages", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "article_tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_tag_id"], name: "index_user_languages_on_article_tag_id"
    t.index ["user_id"], name: "index_user_languages_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "name"
    t.string "title"
    t.text "bio"
    t.string "icon"
    t.string "icon_alt"
    t.string "icon_comment"
    t.boolean "show_adult", default: false
    t.boolean "site_updates", default: false
    t.bigint "sticky_id"
    t.integer "bookmarks_count", default: 0
    t.integer "legacy_password"
    t.text "website"
    t.boolean "notify_follow", default: true
    t.boolean "notify_kudos", default: true
    t.boolean "notify_bookmark", default: true
    t.boolean "notify_reply", default: true
    t.boolean "notify_signal_boost", default: true
    t.boolean "guest", default: false
    t.boolean "tag_editor", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["sticky_id"], name: "index_users_on_sticky_id"
  end

  add_foreign_key "article_taggings", "article_tags"
  add_foreign_key "article_taggings", "articles"
  add_foreign_key "articles", "articles", column: "reply_to_id"
  add_foreign_key "articles", "articles", column: "thread_id"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "comic_pages", "comics"
  add_foreign_key "comics", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "drawings", "users"
  add_foreign_key "gatherings", "items"
  add_foreign_key "ingredients", "items"
  add_foreign_key "ingredients", "preparations"
  add_foreign_key "inventory_entries", "items"
  add_foreign_key "inventory_entries", "users"
  add_foreign_key "legacy_users", "users"
  add_foreign_key "pages", "articles"
  add_foreign_key "preparations", "items", column: "product_id"
  add_foreign_key "series", "users"
  add_foreign_key "series_articles", "articles"
  add_foreign_key "series_articles", "series"
  add_foreign_key "signal_boosts", "articles", column: "origin_id"
  add_foreign_key "statuses", "users"
  add_foreign_key "user_activities", "users"
  add_foreign_key "user_languages", "article_tags"
  add_foreign_key "user_languages", "users"
  add_foreign_key "users", "articles", column: "sticky_id"
end
