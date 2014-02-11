class AddFieldsToMovies < ActiveRecord::Migration
  def self.up
    change_table :movies do |t|
      t.boolean :active
    t.integer :duration
    t.integer :kinopoisk_id
    t.integer :imdb_id
    t.integer :cinemate_id
    end
  end

  def self.down
    change_table :movies do |t|
      t.remove :active
    t.remove :duration
    t.remove :kinopoisk_id
    t.remove :imdb_id
    t.remove :cinemate_id
    end
  end
end
