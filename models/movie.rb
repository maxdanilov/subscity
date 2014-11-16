class Movie < ActiveRecord::Base
	has_many :screenings, primary_key: "movie_id"
	has_many :cinemas, through: :screenings, primary_key: "movie_id"
	has_one :rating, primary_key: "movie_id"
	
	validates :title,  		presence: true
	validates :movie_id, 	presence: true, uniqueness: true

	scope :active, -> { where(:active => true) }

	def format_url
		@format_url ||= format_movie_url(self)
	end

	def has_description?
		@has_descr ||= !get_description.to_s.empty?
	end

	def get_description
		@get_descr ||= ( (description.nil?) ? description_english : description )
	end

	def get_description_formatted
		@get_descr_f ||= get_description.gsub("\r\n", "\n").gsub("\n\n", "<br/>").gsub("\n", "<br/>")
	end

	def valid_genre?
		return true if genres.nil?
		non_valid_genres = ['опера', 'балет', 'фильмы-спектакли', 'оперетты']
		!(non_valid_genres.any? { |w| genres.include? w })
	end

	def russian?
		return true if country == 'Россия'
		return true if (languages == 'Russian' or languages == 'русский')
		return false
	end

	def in_db?
		Movie.where("movie_id = #{movie_id}").size > 0
	end

	def self.are_equal?(a,b)
		a.title == b.title
	end

	def self.get_movie(id)
		Movie.where("movie_id = #{id}").first
	end

	#def self.upd_thumbnail(url)
	#	url.gsub("48x72", "144x212") # too small posters in mobile version
	#end

	def get_screenings(city_id)
		screenings.active.in_city(city_id).order(:date_time)
	end

	def get_next_screening(city_id)
		get_screenings(city_id).first
	end

	def get_sorted_screenings(city_id)
		screenings_all = get_screenings(city_id)
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
		#cinemas = Array.new
		#screenings.active.in_city(city_id).each { |s| cinemas |= [s.cinema_id] }
		#cinemas.size
		#screenings.active.in_city(city_id).select(:cinema_id).uniq.count # slower
		screenings.active.in_city(city_id).pluck(:cinema_id).uniq.count
	end

	def screenings_count(city_id)
		screenings.active.in_city(city_id).count
	end

	def to_s
		"\tMovie: [#{movie_id}][#{id}] #{title} (#{title_original})\n" +
		"\tActive: #{active}\n" +
		"\tKinopoisk, IMDB: #{kinopoisk_id}, #{imdb_id}\n" +
		"\t#{year}; #{country}; #{genres}; Age: #{age_restriction}\n" +
		"\tDirector: #{director}\n" +
		"\tCast: #{cast}\n" +
		"\tDuration: #{duration}\n" +
		"\tPoster: #{poster}\n" +
		"\tCreated: #{created_at}\n" +
		"\tUpdated: #{updated_at}\n"
	end

	def poster_filename
		File.dirname(__FILE__) + "/../public/images/posters/" + movie_id.to_s + ".jpg" 
	end

	def poster_exists?
		File.exist?(poster_filename)
	end

	def timestamp_poster
  		(File.mtime(poster_filename).to_i.to_s) rescue ""
	end

	def thumbnail_poster
		return unless poster_exists?
		img = Magick::Image::read(poster_filename)[0] rescue nil
		return if img.nil?
		max_width = 144
		ratio = img.rows * 1.0 / img.columns
		img = img.thumbnail(max_width, max_width * ratio)
		img.write poster_filename
	end

	def download_poster(url, force_rewrite = false)
		return if url.nil?
		if (!poster_exists? or force_rewrite)
			begin
			   	open(url) do |f|
				   	File.open(poster_filename, "wb") do |file|
				    	file.puts f.read
				   	end
				end
				thumbnail_poster
			rescue
			end
		end
	end
end
