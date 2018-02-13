require_relative 'fetcher_base'

class KassaFetcher
  extend FetcherBase

  DOMAIN = 'https://m.kassa.rambler.ru/'.freeze
  WAPI_DOMAIN = 'https://wapi.kassa.rambler.ru/'.freeze
  DOMAIN_DESKTOP = 'https://kassa.rambler.ru/'.freeze
  HOST = 'm.kassa.rambler.ru'.freeze
  WDOMAIN = 'https://w.kassa.rambler.ru'.freeze
  WIDGET_HOST = 'widget.kassa.rambler.ru'.freeze
  WIDGET_DOMAIN = 'https://widget.kassa.rambler.ru'.freeze
  USER_AGENT = 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) ' +
               'Chrome/64.0.3282.140 Safari/537.36'.freeze
  WIDGET_ID = 16_857
  APPLICATION_KEY = '340fc69e-10f4-423e-a19c-1a5fd3ca94b6'.freeze

  PAGE_SIZE = 20
  READ_TIMEOUT = 5

  JSON_HEADERS = {
    'Connection' => 'keep-alive',
    'Accept' => '*/*',
    'X-Requested-With' => 'XMLHttpRequest',
    'User-Agent' => USER_AGENT,
    'Referer' => DOMAIN,
    'Host' => HOST,
    'Accept-Encoding' => 'gzip,deflate,sdch',
    'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2',
    :read_timeout => READ_TIMEOUT
  }.freeze

  STANDARD_HEADERS = {
    'Connection' => 'keep-alive',
    'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'User-Agent' => USER_AGENT,
    'Referer' => DOMAIN,
    'Host' => HOST,
    'Cache-Control' => 'max-age=0',
    'Accept-Encoding' => 'gzip, deflate, sdch', # NB - if this field is set, content needs to be ungzipped!
    'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2',
    :read_timeout => READ_TIMEOUT
  }.freeze

  WAPI_HEADERS = {
    'Pragma' => 'no-cache',
    'User-Agent' => USER_AGENT,
    'Connection' => 'keep-alive',
    'Accept' => '*/*',
    'Accept-Encoding' => 'gzip,deflate,sdch',
    'Accept-Language' => 'ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2',
    'Referer' => WAPI_DOMAIN,
    'X-Application-Key' => APPLICATION_KEY,
    :read_timeout => READ_TIMEOUT
  }.freeze

  def self.fetch_data_json(url)
    fetch_data(url, JSON_HEADERS)
  end

  def self.fetch_data_html(url, headers = STANDARD_HEADERS)
    fetch_data(url, headers)
  end

  def self.url_for_cinemas(start, length = PAGE_SIZE, place_name)
    # https://m.kassa.rambler.ru/spb/place/nearplaces/17?start=20&pagesize=10&WidgetID=16857
    "#{DOMAIN}#{place_name}/place/nearplaces/17?start=#{start}&pagesize=#{length}&WidgetID=#{WIDGET_ID}"
  end

  def self.url_for_cinema(cinema_id, date = nil, place_id, place_name)
    # https://m.kassa.rambler.ru/place/1907?date=2014.03.12&geoPlaceID=2&widgetid=16857
    # https://m.kassa.rambler.ru/msk/cinema/cinema-1907?date=2016.03.28&WidgetID=16857&geoPlaceID=2
    date = Time.now if date.nil?
    "#{DOMAIN}#{place_name}/cinema/cinema-#{cinema_id}?date=#{date.strftime('%Y.%m.%d')}&geoPlaceID=#{place_id}" \
      "&WidgetID=#{WIDGET_ID}"
  end

  def self.url_for_movies(start, length = PAGE_SIZE, place_id, place_name)
    # https://m.kassa.rambler.ru/spb/creation/topcreations/17?start=20&pagesize=10&WidgetID=16857&GeoPlaceID=3
    "#{DOMAIN}#{place_name}/creation/topcreations/17?start=#{start}&pagesize=#{length}&GeoPlaceID=#{place_id}" \
      "&WidgetID=#{WIDGET_ID}"
  end

  def self.url_for_movie(movie_id)
    # https://kassa.rambler.ru/movie/45849
    "#{DOMAIN_DESKTOP}movie/#{movie_id}"
  end

  def self.url_for_sessions(movie_id, date = nil, _, place_name)
    # https://m.kassa.rambler.ru/spb/movie/53046?date=2014.02.10&WidgetID=16857
    date = Time.now if date.nil?
    "#{DOMAIN}#{place_name}/movie/#{movie_id}?date=#{date.strftime('%Y.%m.%d')}&WidgetID=#{WIDGET_ID}"
  end

  def self.url_for_session(session_id)
    # https://w.kassa.rambler.ru/event/34311975/340fc69e-10f4-423e-a19c-1a5fd3ca94b6/http%3a%2f%2fm.kassa.rambler.ru%2f
    origin = DOMAIN.gsub('/', '%2f').gsub(':', '%3a')
    "#{WDOMAIN}/event/#{session_id}/#{APPLICATION_KEY}/#{origin}"
  end

  def self.url_for_session_ticket_details(session_id)
    # https://wapi.kassa.rambler.ru/sessions/34289567/hallstate
    "#{WAPI_DOMAIN}sessions/#{session_id}/hallstate"
  end

  def self.url_for_session_details(session_id)
    # https://wapi.kassa.rambler.ru/sessions/34289567
    "#{WAPI_DOMAIN}sessions/#{session_id}"
  end

  def self.url_for_cinema_sessions(cinema_id, date)
    # https://wapi.kassa.rambler.ru/places/311/schedule/2018-02-11
    "#{WAPI_DOMAIN}places/#{cinema_id}/schedule/#{date.strftime('%Y-%m-%d')}"
  end

  def self.url_for_movie_sessions(movie_id, date, city_id)
    # https://wapi.kassa.rambler.ru/creations/movie/91971/schedule/2018-02-11/city/3
    "#{WAPI_DOMAIN}creations/movie/#{movie_id}/schedule/#{date.strftime('%Y-%m-%d')}/city/#{city_id}"
  end

  def self.fetch_session_tickets(session_id)
    fetch_data_html(url_for_session_ticket_details(session_id), WAPI_HEADERS)
  end

  def self.fetch_session(session_id)
    fetch_data_html(url_for_session_details(session_id), WAPI_HEADERS)
  end

  def self.fetch_movies(start, length = PAGE_SIZE, place_id, place_name)
    fetch_data_json(url_for_movies(start, length, place_id, place_name))
  end

  def self.fetch_movie(movie_id)
    fetch_data_html(url_for_movie(movie_id), {})
  end

  def self.fetch_cinemas(start, length = PAGE_SIZE, _place_id, place_name)
    fetch_data_json(url_for_cinemas(start, length, place_name))
  end

  def self.fetch_cinema(cinema_id, date = nil, place_id, place_name)
    fetch_data_html(url_for_cinema(cinema_id, date, place_id, place_name))
  end

  def self.fetch_sessions(movie_id, date = nil, place_id, place_name)
    fetch_data_html(url_for_sessions(movie_id, date, place_id, place_name))
  end

  def self.fetch_cinema_sessions(cinema_id, date)
    fetch_data_html(url_for_cinema_sessions(cinema_id, date), WAPI_HEADERS)
  end

  def self.fetch_movie_sessions(movie_id, date, city_id)
    fetch_data_html(url_for_movie_sessions(movie_id, date, city_id), WAPI_HEADERS)
  end

  private_class_method :url_for_sessions
  private_class_method :url_for_movies
  private_class_method :url_for_movie
  private_class_method :url_for_cinemas
  private_class_method :fetch_data_html
  private_class_method :fetch_data_json

  public_class_method :fetch_sessions
  public_class_method :fetch_cinemas
  public_class_method :fetch_movies
  public_class_method :fetch_movie
  public_class_method :fetch_session
end
