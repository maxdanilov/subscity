ActiveRecord::Schema.define(version: 7) do
  create_table 'accounts', force: true do |t|
    t.string   'email'
    t.string   'crypted_password'
    t.string   'role'
    t.datetime 'created_at',       null: false
    t.datetime 'updated_at',       null: false
  end

  create_table 'cinemas', force: true do |t|
    t.integer  'cinema_id'
    t.integer  'city_id'
    t.string   'name'
    t.string   'address'
    t.string   'metro'
    t.string   'url'
    t.string   'phone'
    t.boolean  'fetch_all',  default: false, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.decimal  'longitude',  precision: 15, scale: 10
    t.decimal  'latitude',   precision: 15, scale: 10
  end

  add_index 'cinemas', %w[cinema_id city_id], name: 'cinema_id'

  create_table 'cities', force: true do |t|
    t.boolean  'active'
    t.string   'domain'
    t.integer  'city_id'
    t.string   'name'
    t.string   'name_short', null: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  create_table 'movies', force: true do |t|
    t.integer  'movie_id'
    t.boolean  'active'
    t.string   'title'
    t.string   'title_original'
    t.string   'languages'
    t.text     'description'
    t.text     'description_english'
    t.string   'director'
    t.text     'cast'
    t.integer  'age_restriction'
    t.string   'country'
    t.integer  'year'
    t.string   'genres'
    t.text     'poster'
    t.integer  'duration'
    t.integer  'kinopoisk_id'
    t.integer  'imdb_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string   'trailer'
    t.integer  'fetch_mode', limit: 1, default: 0, null: false
    t.boolean  'hide'
  end

  create_table 'ratings', force: true do |t|
    t.datetime 'updated_at'
    t.datetime 'created_at'
    t.integer  'movie_id'
    t.float    'kinopoisk_rating'
    t.integer  'kinopoisk_votes'
    t.float    'imdb_rating'
    t.integer  'imdb_votes'
  end

  add_index 'ratings', ['id'], name: 'id', unique: true

  create_table 'screenings', force: true do |t|
    t.integer  'movie_id'
    t.integer  'cinema_id'
    t.datetime 'date_time'
    t.integer  'price_min'
    t.integer  'price_max'
    t.integer  'screening_id'
    t.datetime 'created_at',   null: false
    t.datetime 'updated_at',   null: false
  end

  add_index 'screenings', ['cinema_id'], name: 'cinema_id'
end
