require 'date'

class Screening < ActiveRecord::Base
  belongs_to :cinema, primary_key: 'cinema_id'
  belongs_to :movie, primary_key: 'movie_id'
  has_one :city, through: :cinema, primary_key: 'city_id'

  validates :screening_id, presence: true, uniqueness: true
  validates :movie_id, presence: true
  validates :cinema_id, presence: true

  scope :later_than, ->(date) { where('date_time > ?', date) }
  scope :before, ->(date) { where('date_time <= ?', date) }
  scope :today, -> { where(date_time: time_range_on_day(Time.now)) }
  scope :on_date, ->(date) { where(date_time: time_range_on_day(date)) }
  scope :no_prices, -> { where(price_min: nil) }
  scope :with_prices, -> { where('price_min > ?', 0) }

  scope :active, lambda {
    where('date_time > ? AND date_time <= ?', Time.now,
          Time.now.strip + 1.day + SETTINGS[:new_day_starts_at] + SETTINGS[:screenings_show_span].days)
  }
  scope :active_all, -> { where('date_time > ?', Time.now) }
  scope :inactive, -> { where('date_time <= ?', Time.now) }

  scope :active_feed, lambda {
    where('date_time > ? AND date_time < ?',
          Time.now + SETTINGS[:screenings_feed_start], Time.now + SETTINGS[:screenings_feed_end])
  }

  scope :in_city, ->(city_id) { joins(:cinema).where('city_id = ?', city_id) }

  def self.get_sorted_screenings(date, city_id, active_all = false)
    screenings_all = if active_all
                       Screening.active_all.on_date(date).in_city(city_id).order(:date_time)
                     else
                       Screening.active.on_date(date).in_city(city_id).order(:date_time)
                     end
    cinemas_all = Cinema.all
    movies_all = Movie.all.reject(&:russian?)
    r = {}
    # format is like this: r[movie][cinema] -> array of screenings
    screenings_all.each do |s|
      cinema = cinemas_all.find { |c| c.cinema_id == s.cinema_id }
      movie = movies_all.find { |c| c.movie_id == s.movie_id }
      r[movie] ||= {} unless movie.nil?
      unless cinema.nil? || movie.nil?
        r[movie][cinema] ||= []
        r[movie][cinema] << s
      end
    end

    r.each { |k, v| r[k] = v.sort_by { |k1, _v1| k1.name }.to_h } # sort cinemas by name
    r = Hash[r.sort_by { |k, _v| k.title }] # sort movies by title
  end

  def date
    date_for_screening(date_time).to_date
  end

  def session_data
    @session_data ||= KassaFetcher.fetch_session(screening_id)
  end

  def session_tickets_data
    @session_tickets_data ||= KassaFetcher.fetch_session_tickets(screening_id)
  end

  def exists?
    KassaParser.screening_exists?(session_tickets_data)
  end

  def actual_title
    KassaParser.screening_title(session_data)
  end

  def kassa_movie_id
    KassaParser.screening_movie_id(session_data)
  end

  def subs?
    KassaParser.screening_has_subs?(session_data)
  end

  def correct_movie_id?
    kassa_movie_id == movie.movie_id
  end

  def actual_date_time
    KassaParser.screening_date_time(session_data)
  end

  def prices
    KassaParser.parse_prices(session_tickets_data)
  end

  def tickets_url
    KassaFetcher.url_for_session(screening_id)
  end

  def render_json(cinemas, movies)
    json_data = as_json(only: %w[id date_time price_min price_max])
    json_data['cinema_id'] = cinemas.find { |c| c.cinema_id == cinema_id }.id rescue nil
    json_data['movie_id'] = movies.find { |m| m.movie_id == movie_id }.id rescue nil
    json_data['tickets_url'] = "#{full_domain_name}/screenings/tickets/#{id}"
    json_data.sort.to_h
  end

  def to_s
    "\tScreening: [#{screening_id}] #{id}\n" \
    "\tMovie: [#{movie_id}] #{movie.title}\n" \
    "\tCinema: [#{cinema_id}] #{cinema.name}\n" \
    "\tTime: #{date_time}\n" \
    "\tPrices: [#{price_min}, #{price_max}]\n" \
    "\tCreated: #{created_at}\n" \
    "\tUpdated: #{updated_at}\n"
  end
end
