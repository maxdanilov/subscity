class Movie < ActiveRecord::Base
	has_many :screenings, primary_key: "movie_id"
	has_many :cinemas, through: :screenings, primary_key: "movie_id"
	
	validates :title,  		presence: true
	validates :movie_id, 	presence: true, uniqueness: true

	scope :active, -> { where(:active => true) }

	def valid_genre?
		non_valid_genres = ['Опера', 'Балет', 'Фильмы-спектакли']
		!(non_valid_genres.any? { |w| genres.include? w })
	end

	def in_db?
		Movie.where("movie_id = #{movie_id}").size > 0
	end

	def self.get_movie(id)
		Movie.where("movie_id = #{id}").first
	end

	def self.upd_thumbnail(url)
		url.gsub("48x72", "144x212") # too small posters in mobile version
	end

	def get_sorted_screenings(city_id)
		screenings_all = screenings.active.in_city(city_id).order(:date_time)
		cinemas_all = Cinema.all
		r = Hash.new
		# format is like this: r["2014-02-17"][cinema] -> array of screenings
		screenings_all.each do |s|
			r[s.date.to_s] ||= {}
			cinema = cinemas_all.find { |c| c.cinema_id == s.cinema_id}#.name
			unless cinema.nil?
				r[s.date.to_s][cinema] ||= []
				r[s.date.to_s][cinema] << s
			end
		end

		r.each { |k,v| r[k] = v.sort_by {|k,v| k.name}.to_h } # sort cinemas by name
		r
	end

	def cinemas_count(city_id)
		cinemas = Array.new
		screenings.active.in_city(city_id).each { |s| cinemas |= [s.cinema_id] }
		cinemas.size
	end

	def screenings_count(city_id)
		screenings.active.in_city(city_id).count
	end

	def to_s
		"\tMovie: [#{movie_id}][#{id}] #{title} (#{title_original})\n" +
		"\tActive: #{active}\n" +
		"\tCinemate, Kinopoisk, IMDB: #{cinemate_id}, #{kinopoisk_id}, #{imdb_id}\n" +
		"\t#{year}; #{country}; #{genres}; Age: #{age_restriction}\n" +
		"\tDirector: #{director}\n" +
		"\tCast: #{cast}\n" +
		"\tDuration: #{duration}\n" +
		"\tPoster: #{poster}\n" +
		"\tCreated: #{created_at}\n" +
		"\tUpdated: #{updated_at}\n"
	end

end
