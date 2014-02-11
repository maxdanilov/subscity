class AddFieldsToScreenings < ActiveRecord::Migration
  def self.up
    change_table :screenings do |t|
      t.integer :screening_id
    end
  end

  def self.down
    change_table :screenings do |t|
      t.remove :screening_id
    end
  end
end
