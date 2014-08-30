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

ActiveRecord::Schema.define(version: 20140822113010) do

  create_table "accounts", force: true do |t|
    t.string   "company_name",                                      null: false
    t.string   "email",                                             null: false
    t.integer  "plan_id",                                           null: false
    t.integer  "paused_plan_id"
    t.boolean  "active",                             default: true, null: false
    t.string   "address_line1",          limit: 120
    t.string   "address_line2",          limit: 120
    t.string   "address_city",           limit: 120
    t.string   "address_zip",            limit: 20
    t.string   "address_state",          limit: 60
    t.string   "address_country",        limit: 2
    t.string   "card_token",             limit: 60
    t.string   "stripe_customer_id",     limit: 60
    t.string   "stripe_subscription_id", limit: 60
    t.string   "cancellation_category"
    t.string   "cancellation_reason"
    t.string   "cancellation_message"
    t.datetime "cancelled_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", using: :btree
  add_index "accounts", ["paused_plan_id"], name: "index_accounts_on_paused_plan_id", using: :btree
  add_index "accounts", ["plan_id"], name: "index_accounts_on_plan_id", using: :btree
  add_index "accounts", ["stripe_customer_id"], name: "index_accounts_on_stripe_customer_id", unique: true, using: :btree
  add_index "accounts", ["stripe_subscription_id"], name: "index_accounts_on_stripe_subscription_id", unique: true, using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "plans", force: true do |t|
    t.string   "stripe_id",             limit: 80
    t.string   "name",                  limit: 80,                    null: false
    t.string   "statement_description", limit: 150
    t.boolean  "active",                            default: true,    null: false
    t.boolean  "public",                            default: true,    null: false
    t.integer  "paused_plan_id"
    t.string   "currency",              limit: 3,   default: "USD",   null: false
    t.integer  "interval_count",                    default: 1,       null: false
    t.string   "interval",              limit: 5,   default: "month", null: false
    t.integer  "amount",                            default: 0,       null: false
    t.integer  "trial_period_days",                 default: 30,      null: false
    t.integer  "max_users",                         default: 1,       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plans", ["paused_plan_id"], name: "index_plans_on_paused_plan_id", using: :btree
  add_index "plans", ["stripe_id"], name: "index_plans_on_stripe_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "first_name",             limit: 60
    t.string   "last_name",              limit: 60
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",                   default: 0,     null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.boolean  "super_admin",                       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

end
