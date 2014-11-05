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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 7) do

  create_table "accounts", :force => true do |t|
    t.string   "name"
    t.string   "surname"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "role"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "cinemas", :force => true do |t|
    t.integer  "cinema_id"
    t.integer  "city_id"
    t.string   "name"
    t.string   "address"
    t.string   "metro"
    t.string   "url"
    t.string   "phone"
    t.boolean  "fetch_all"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "cities", :force => true do |t|
    t.boolean  "active"
    t.string   "geoip"
    t.string   "domain"
    t.integer  "city_id"
    t.string   "name"
    t.string   "name_short"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "movies", :force => true do |t|
    t.integer  "movie_id"
    t.boolean  "active"
    t.string   "title"
    t.string   "title_original"
    t.string   "languages"
    t.text     "description"
    t.string   "director"
    t.text     "cast"
    t.integer  "age_restriction"
    t.string   "country"
    t.integer  "year"
    t.string   "genres"
    t.text     "poster"
    t.integer  "duration"
    t.integer  "kinopoisk_id"
    t.integer  "imdb_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.string   "trailer"
  end

  create_table "screenings", :force => true do |t|
    t.integer  "movie_id"
    t.integer  "cinema_id"
    t.datetime "date_time"
    t.integer  "price_min"
    t.integer  "price_max"
    t.integer  "screening_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "ratings", :force => true do |t|
    t.integer  "movie_id"
    t.real     "kinopoisk_rating"
    t.integer  "kinopoisk_votes"
    t.real     "imdb_rating"
    t.integer  "imdb_votes"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end
end
