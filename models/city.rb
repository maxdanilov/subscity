class City < ActiveRecord::Base
	has_many :cinemas, primary_key: "city_id"

	validates :name, presence: true, uniqueness: true
	validates :city_id, presence: true, uniqueness: true
end
