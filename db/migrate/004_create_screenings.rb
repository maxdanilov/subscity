class CreateScreenings < ActiveRecord::Migration
  def self.up
    create_table :screenings do |t|
      t.integer :movie_id
      t.integer :cinema_id
      t.datetime :date_time
      t.integer :price_min
      t.integer :price_max
      t.timestamps
    end
  end

  def self.down
    drop_table :screenings
  end
end
