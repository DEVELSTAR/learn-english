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

ActiveRecord::Schema[8.1].define(version: 2026_10_19_183500) do
  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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

  create_table "lesson_blocks", force: :cascade do |t|
    t.integer "lesson_id", null: false
    t.string "block_type", null: false
    t.json "content", default: {}
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id", "position"], name: "index_lesson_blocks_on_lesson_id_and_position"
    t.index ["lesson_id"], name: "index_lesson_blocks_on_lesson_id"
  end

  create_table "lesson_chat_messages", force: :cascade do |t|
    t.integer "lesson_id", null: false
    t.integer "user_id", null: false
    t.string "role", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id", "user_id", "created_at"], name: "idx_on_lesson_id_user_id_created_at_f5acf941bb"
    t.index ["lesson_id"], name: "index_lesson_chat_messages_on_lesson_id"
    t.index ["user_id"], name: "index_lesson_chat_messages_on_user_id"
  end

  create_table "lesson_comments", force: :cascade do |t|
    t.integer "lesson_id", null: false
    t.integer "user_id", null: false
    t.integer "parent_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id", "created_at"], name: "index_lesson_comments_on_lesson_id_and_created_at"
    t.index ["lesson_id"], name: "index_lesson_comments_on_lesson_id"
    t.index ["parent_id"], name: "index_lesson_comments_on_parent_id"
    t.index ["user_id"], name: "index_lesson_comments_on_user_id"
  end

  create_table "lesson_completions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "lesson_id", null: false
    t.boolean "completed", default: false, null: false
    t.boolean "needs_revision", default: false, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lesson_id"], name: "index_lesson_completions_on_lesson_id"
    t.index ["user_id", "lesson_id"], name: "index_lesson_completions_on_user_id_and_lesson_id", unique: true
    t.index ["user_id"], name: "index_lesson_completions_on_user_id"
  end

  create_table "lessons", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.date "lesson_date", null: false
    t.string "topic"
    t.text "introduction"
    t.integer "status", default: 0, null: false
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lesson_type", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.index ["author_id"], name: "index_lessons_on_author_id"
    t.index ["lesson_date"], name: "index_lessons_on_lesson_date"
    t.index ["lesson_type"], name: "index_lessons_on_lesson_type"
    t.index ["position"], name: "index_lessons_on_position"
    t.index ["slug"], name: "index_lessons_on_slug", unique: true
    t.index ["status"], name: "index_lessons_on_status"
  end

  create_table "notes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["user_id", "created_at"], name: "index_notes_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "lesson_blocks", "lessons", on_delete: :cascade
  add_foreign_key "lesson_chat_messages", "lessons"
  add_foreign_key "lesson_chat_messages", "users"
  add_foreign_key "lesson_comments", "lesson_comments", column: "parent_id"
  add_foreign_key "lesson_comments", "lessons"
  add_foreign_key "lesson_comments", "users"
  add_foreign_key "lesson_completions", "lessons", on_delete: :cascade
  add_foreign_key "lesson_completions", "users", on_delete: :cascade
  add_foreign_key "lessons", "users", column: "author_id"
  add_foreign_key "notes", "users"
  add_foreign_key "sessions", "users"
end
