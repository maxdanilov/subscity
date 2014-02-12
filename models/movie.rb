class Movie < ActiveRecord::Base
	has_many :screenings, primary_key: "movie_id"
	has_many :cinemas, through: :screenings, primary_key: "movie_id"
	
	validates :name,  		presence: true
	validates :movie_id, 	presence: true, uniqueness: true

	def in_db?
		Movie.where("movie_id = #{movie_id}").size > 0
	end

	def self.get_movie(id)
		Movie.where("movie_id = #{id}").first
	end

	def self.upd_thumbnail(url)
		url.gsub("48x72", "144x212") # too small posters in mobile version
	end

end
