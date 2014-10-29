class City < ActiveRecord::Base
	has_many :cinemas, primary_key: "city_id"

	validates :name, presence: true, uniqueness: true
	validates :city_id, presence: true, uniqueness: true

	scope :active, -> { where(:active => true) }

	def get_sorted_cinemas
		screenings_all = Screening.active.in_city(city_id).order(:date_time)
		movies_all = Movie.all.select { |m| not m.russian? }
		cinemas_all = Cinema.where(:city_id => city_id)
		r = Hash.new
		# format is like this: r[cinema][movie] = screenings count
		screenings_all.each do |s|
			cinema = cinemas_all.find { |c| c.cinema_id == s.cinema_id}
			movie = movies_all.find { |c| c.movie_id == s.movie_id}
			unless cinema.city_id != city_id
				unless cinema.nil? or movie.nil?
					r[cinema] ||= {}
					r[cinema][movie] ||= 0
					r[cinema][movie] += 1
				end
			end
		end
		r = r.sort_by {|k,v| k.name }.to_h # sort cinemas by name
		r.each { |k,v| r[k] = v.sort_by {|k,v| k.title}.to_h } # sort movies by title
		r
	end

	def get_movies
		Movie.joins(:screenings).merge(Screening.active.in_city(city_id)).uniq.select { |m| not m.russian? }
		#Movie.joins(:screenings).merge(Screening.active.joins(:cinema).where("city_id = ?", city_id)).uniq
	end

	def get_cinemas
		Cinema.where(:city_id => city_id)
	end

	def self.get_by_domain(domain)
		City.where(:domain => domain).first rescue nil
	end
end
