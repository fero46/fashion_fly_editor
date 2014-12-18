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

ActiveRecord::Schema.define(version: 20141218155820) do

  create_table "fashion_fly_editor_categories", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fashion_fly_editor_categories", ["parent_id", "parent_type"], name: "category_parent"
  add_index "fashion_fly_editor_categories", ["slug"], name: "index_fashion_fly_editor_categories_on_slug", unique: true

  create_table "fashion_fly_editor_collection_items", force: true do |t|
    t.integer  "collection_id"
    t.integer  "item_id"
    t.integer  "position_x"
    t.integer  "position_y"
    t.float    "width"
    t.float    "height"
    t.float    "rotation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "scale_x"
    t.integer  "scale_y"
    t.integer  "order",         default: 0
  end

  create_table "fashion_fly_editor_collections", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.integer  "user_id"
    t.integer  "height"
    t.integer  "width"
  end

  add_index "fashion_fly_editor_collections", ["category_id"], name: "index_fashion_fly_editor_collections_on_category_id"
  add_index "fashion_fly_editor_collections", ["user_id"], name: "index_fashion_fly_editor_collections_on_user_id"

  create_table "fashion_fly_editor_subscriptions", force: true do |t|
    t.integer  "collection_id"
    t.integer  "subscriber_id"
    t.string   "subscriber_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fashion_fly_editor_subscriptions", ["collection_id"], name: "index_fashion_fly_editor_subscriptions_on_collection_id"
  add_index "fashion_fly_editor_subscriptions", ["subscriber_id", "subscriber_type"], name: "subscriber"

  create_table "scopes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
