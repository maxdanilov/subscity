class Cinema < ActiveRecord::Base
	belongs_to :city, primary_key: "city_id"
	has_many :screenings, primary_key: "cinema_id"
	has_many :movies, through: :screenings, primary_key: "cinema_id"

	validates :cinema_id,   presence: true, uniqueness: true
	validates :name,  		presence: true
	validates :city_id, 	presence: true
	
end
