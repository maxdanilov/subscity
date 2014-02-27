class Cinema < ActiveRecord::Base
	belongs_to :city, primary_key: "city_id"
	has_many :screenings, primary_key: "cinema_id"
	has_many :movies, through: :screenings, primary_key: "cinema_id"

	validates :cinema_id,   presence: true, uniqueness: true
	validates :name,  		presence: true
	validates :city_id, 	presence: true
	
	def get_sorted_screenings
		screenings_all = Screening.active.where(:cinema_id => cinema_id).order(:date_time)
		movies_all = Movie.all
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

end
