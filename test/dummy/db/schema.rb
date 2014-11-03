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

ActiveRecord::Schema.define(version: 20141103111820) do

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
  end

  create_table "fashion_fly_editor_collections", force: true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
