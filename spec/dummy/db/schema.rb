# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151117225238) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "api_guardian_permissions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "api_guardian_role_permissions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "role_id"
    t.uuid     "permission_id"
    t.boolean  "granted",       default: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "api_guardian_roles", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name"
    t.boolean  "default",    default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "api_guardian_users", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "email_confirmed_at"
    t.string   "phone_number"
    t.datetime "phone_number_confirmed_at"
    t.string   "password_digest",                           null: false
    t.boolean  "active",                    default: false
    t.uuid     "role_id",                                   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string   "otp_secret_key"
    t.boolean  "otp_enabled",               default: false
    t.string   "otp_method",                default: "sms"
    t.datetime "deleted_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "api_guardian_users", ["deleted_at"], name: "index_api_guardian_users_on_deleted_at", using: :btree
  add_index "api_guardian_users", ["email"], name: "index_api_guardian_users_on_email", unique: true, using: :btree
  add_index "api_guardian_users", ["reset_password_token"], name: "index_api_guardian_users_on_reset_password_token", unique: true, using: :btree
  add_index "api_guardian_users", ["role_id"], name: "index_api_guardian_users_on_role_id", using: :btree

  create_table "oauth_access_grants", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "resource_owner_id", null: false
    t.uuid     "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "resource_owner_id"
    t.uuid     "application_id"
    t.text     "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

end
