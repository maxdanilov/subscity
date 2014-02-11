class CreateMovies < ActiveRecord::Migration
  def self.up
    create_table :movies do |t|
      t.integer :movie_id
      t.string :name
      t.integer :age_restriction
      t.string :country
      t.integer :year
      t.string :genres
      t.text :thumbnail
      t.timestamps
    end
  end

  def self.down
    drop_table :movies
  end
end
