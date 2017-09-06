class Cinema < ActiveRecord::Base
	belongs_to :city, primary_key: "city_id"
	has_many :screenings, primary_key: "cinema_id"
	has_many :movies, through: :screenings, primary_key: "cinema_id"

	validates :cinema_id,   presence: true, uniqueness: true
	validates :name,  		presence: true
	validates :city_id, 	presence: true

	def format_url
		@forman_url ||= format_cinema_url(self)
	end

	def get_sorted_screenings(active_all = false)
		if active_all == true
			screenings_all = Screening.active_all.where(:cinema_id => cinema_id).order(:date_time)
		else
			screenings_all = Screening.active.where(:cinema_id => cinema_id).order(:date_time)
		end
		movies_all = Movie.all.select { |m| not m.russian? }
		r = Hash.new
		# format is like this: r["2014-02-17"][cinema] -> array of screenings
		screenings_all.each do |s|
			r[s.date.to_s] ||= {}
			movie = movies_all.find { |c| c.movie_id == s.movie_id}#.name
			unless movie.nil?
				r[s.date.to_s][movie] ||= []
				r[s.date.to_s][movie] << s
			end
		end

		r.each { |k,v| r[k] = v.sort_by {|k,v| k.title}.to_h } # sort movies by title
		r
	end

	def render_json(movies)
		data = as_json(:only => ['id', 'name'])
		data['phones'] = phone.to_s.empty? ? nil : phone.split(", ")
		data['urls'] = url.to_s.empty? ? nil : url.split(", ")
		data['movies_count'] = movies.length rescue 0
		data['movies'] = movies.map { |m, v| m.id } rescue []
		data['location'] = {
			'address': address,
			'metro': metro.to_s.empty? ? nil : metro.split(", "),
			'latitude': latitude.to_s.empty? ? nil : latitude.to_f,
			'longitude': longitude.to_s.empty? ? nil : longitude.to_f
		}
		data.sort.to_h
	end
end
