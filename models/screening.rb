class Screening < ActiveRecord::Base
	belongs_to :cinema, primary_key: "cinema_id"
	belongs_to :movie, primary_key: "movie_id"

	validates :screening_id, presence: true, uniqueness: true
	validates :movie_id, presence: true
	validates :cinema_id, presence: true

	scope :later_than, ->(date) { where('date_time > ?', date) }
	scope :before, ->(date) { where('date_time <= ?', date) }
	scope :today, -> { where(:date_time => time_range_on_day(Time.now) ) }
	scope :on_date, ->(date) { where(:date_time => time_range_on_day(date)) }
	scope :no_prices, -> { where(:price_max => nil) }

	scope :active, -> { where('date_time > ?', Time.now) }
	scope :inactive, -> { where('date_time <= ?', Time.now) }

	def exists?
		KassaParser.screening_exists?(KassaFetcher.fetch_session(screening_id, cinema.city_id))
	end

	def available?
		KassaParser.parse_tickets_available?(KassaFetcher.fetch_availability(screening_id))
	end

	def get_prices
		KassaParser.parse_prices(KassaFetcher.fetch_prices(screening_id))
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
