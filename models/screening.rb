require 'date'

class Screening < ActiveRecord::Base
	belongs_to :cinema, primary_key: "cinema_id"
	belongs_to :movie, primary_key: "movie_id"
	has_one :city, through: :cinema, primary_key: "city_id"

	validates :screening_id, presence: true, uniqueness: true
	validates :movie_id, presence: true
	validates :cinema_id, presence: true

	scope :later_than, ->(date) { where('date_time > ?', date) }
	scope :before, ->(date) { where('date_time <= ?', date) }
	scope :today, -> { where(:date_time => time_range_on_day(Time.now) ) }
	#scope :today_and_later, -> { where('date_time > ?', Time.now.strip) }
	scope :on_date, ->(date) { where(:date_time => time_range_on_day(date)) }
	scope :no_prices, -> { where(:price_max => nil) }

	scope :active, -> { where('date_time > ? AND date_time <= ?', Time.now, Time.now.strip + 1.day + SETTINGS[:new_day_starts_at] + SETTINGS[:screenings_show_span].days) }
	scope :active_all, -> { where('date_time > ?', Time.now) }
	scope :inactive, -> { where('date_time <= ?', Time.now) }

	scope :active_feed, -> { where('date_time > ? AND date_time < ?', Time.now + SETTINGS[:screenings_feed_start], Time.now + SETTINGS[:screenings_feed_end]) }

	scope :in_city, ->(city_id) { joins(:cinema).where("city_id = ?", city_id) }

	def self.get_sorted_screenings(date, city_id, active_all = false)
		if active_all == true
			screenings_all = Screening.active_all.on_date(date).in_city(city_id).order(:date_time)
		else
			screenings_all = Screening.active.on_date(date).in_city(city_id).order(:date_time)
		end
		cinemas_all = Cinema.all
		movies_all = Movie.all.select { |m| not m.russian? }
		r = Hash.new
		# format is like this: r[movie][cinema] -> array of screenings
		screenings_all.each do |s|
			cinema = cinemas_all.find { |c| c.cinema_id == s.cinema_id}
			movie = movies_all.find { |c| c.movie_id == s.movie_id}
			r[movie] ||= {} unless movie.nil?
			unless cinema.nil? or movie.nil?
				r[movie][cinema] ||= []
				r[movie][cinema] << s
			end
		end

		r.each { |k,v| r[k] = v.sort_by {|k,v| k.name}.to_h } # sort cinemas by name
		r = Hash[r.sort_by {|k,v| k.title}] #sort movies by title
	end

	def date
		date_for_screening(date_time).to_date
	end

	def session_data
		@session_data ||= KassaFetcher.fetch_session(screening_id, cinema.city_id)
	end

	def exists?
		#puts "Checking if exists: #{screening_id}".cyan
		KassaParser.screening_exists?(session_data)
	end

	def actual_title
		title = KassaParser.screening_title(session_data)
	end

	def has_subs?
		KassaParser.screening_has_subs?(session_data)
	end

	def has_correct_title?
		title = actual_title
		(movie.title.mb_chars.downcase.to_s.include? title.mb_chars.downcase.to_s or title.mb_chars.downcase.to_s.include? movie.title.mb_chars.downcase.to_s) rescue false
	end

	def available?
		KassaParser.parse_tickets_available?(KassaFetcher.fetch_availability(screening_id))
	end

	def actual_date_time
		KassaParser.screening_date_time(session_data)
	end

	def get_prices
		#KassaParser.parse_prices(KassaFetcher.fetch_prices(screening_id))
		KassaParser.parse_prices_full(KassaFetcher.fetch_prices_full(screening_id))
	end

	def to_s
		"\tScreening: [#{screening_id}] #{id}\n" +
		"\tMovie: [#{movie_id}] #{movie.title}\n" +
		"\tCinema: [#{cinema_id}] #{cinema.name}\n" +
		"\tTime: #{date_time}\n" +
		"\tPrices: [#{price_min}, #{price_max}]\n" +
		"\tCreated: #{created_at}\n" +
		"\tUpdated: #{updated_at}\n"
	end
end
