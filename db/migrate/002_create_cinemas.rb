class CreateCinemas < ActiveRecord::Migration
  def self.up
    create_table :cinemas do |t|
      t.integer :cinema_id
      t.integer :city_id
      t.text :name
      t.text :address
      t.text :metro
      t.timestamps
    end
  end

  def self.down
    drop_table :cinemas
  end
end
