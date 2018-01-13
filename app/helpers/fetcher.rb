require_relative 'fetcher_base'

class KassaFetcher
	extend FetcherBase

	DOMAIN = "https://m.kassa.rambler.ru/"
	DOMAIN_DESKTOP = "https://kassa.rambler.ru/"
	HOST = "m.kassa.rambler.ru"
	WIDGET_HOST = "widget.kassa.rambler.ru"
	WIDGET_DOMAIN = "https://widget.kassa.rambler.ru"
	USER_AGENT = "Opera/12.02 (Android 4.1; Linux; Opera Mobi/ADR-1111101157; U; en-US) Presto/2.9.201 Version/12.02"
	WIDGET_ID = 16857

	PAGE_SIZE = 20
	#CITY_ID = 2
	URL_FOR_PRICES = 'http://m.kassa.rambler.ru/place/hallplanajax'
	READ_TIMEOUT = 5

	JSON_HEADERS =	   {	"Connection" => "keep-alive",
							"Accept" => "*/*",
							"X-Requested-With" => "XMLHttpRequest",
							"User-Agent" => USER_AGENT,
							"Referer" => DOMAIN,
							"Host" => HOST,
							"Accept-Encoding" => "gzip,deflate,sdch",
							"Accept-Language" => "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2",
							:read_timeout => READ_TIMEOUT
						}

	STANDARD_HEADERS = {
							"Connection" => "keep-alive",
							"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
							"User-Agent" => USER_AGENT,
							"Referer" => DOMAIN,
							"Host" => HOST,
							"Cache-Control" => "max-age=0",
							"Accept-Encoding" => "gzip, deflate, sdch", #attention - if this field is set, content needs to be ungzipped!
							"Accept-Language" => "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2",
							:read_timeout => READ_TIMEOUT
						}

	JSON_HEADERS_WIDGET = { "Connection" => "keep-alive",
							"Accept" => "*/*",
							"X-Requested-With" => "XMLHttpRequest",
							"User-Agent" => USER_AGENT,
							"Referer" => WIDGET_DOMAIN,
							"Host" => WIDGET_HOST,
							"Accept-Encoding" => "gzip,deflate,sdch",
							"Accept-Language" => "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2",
							:read_timeout => READ_TIMEOUT
						}

	def self.fetch_data_json(url)
		fetch_data(url, JSON_HEADERS)
	end

	def self.fetch_data_html(url)
		fetch_data(url, STANDARD_HEADERS)
	end

	def self.fetch_data_html_no_headers(url)
		fetch_data(url, {})
	end

	def self.fetch_prices(screening_id)
		fetch_data_post(URL_FOR_PRICES, params_for_prices(screening_id), STANDARD_HEADERS)
	end

	def self.fetch_prices_full(screening_id)
		# https://widget.kassa.rambler.ru/place/hallplanajax/9889099?widgetid=16043&clusterradius=61
		url = "#{WIDGET_DOMAIN}/place/hallplanajax/#{screening_id}?widgetid=16043&clusterradius=61"
		fetch_data(url, JSON_HEADERS_WIDGET)
	end

	def self.fetch_availability(screening_id)
		fetch_data_html(url_for_availability(screening_id))
	end

	def self.params_for_availability(screening_id)
		{ 'sessionid' => screening_id.to_s }
	end

	def self.params_for_prices(screening_id)
		{ 'sessionID' => screening_id, 'placeCount' => 1, 'widgetID' => WIDGET_ID }
	end

	def self.url_for_availability(screening_id)
		# https://m.kassa.rambler.ru/place/placecount?sessionid=28665397
		"#{DOMAIN}place/placecount?sessionid=#{screening_id}"
	end

	def self.url_for_cinemas(start, length = PAGE_SIZE, place_id, place_name)
		# https://m.kassa.rambler.ru/spb/place/nearplaces/cinema?start=20&pagesize=10&WidgetID=16857&GeoPlaceID=3
		"#{DOMAIN}#{place_name}/place/nearplaces/cinema?start=#{start}&pagesize=#{length}&GeoPlaceID=#{place_id}&WidgetID=#{WIDGET_ID}"
	end

	def self.url_for_cinema(cinema_id, date = nil, place_id, place_name)
		# https://m.kassa.rambler.ru/place/1907?date=2014.03.12&geoPlaceID=2&widgetid=16857
		# https://m.kassa.rambler.ru/msk/cinema/cinema-1907?date=2016.03.28&WidgetID=16857&geoPlaceID=2
		date = Time.now if date.nil?
		"#{DOMAIN}#{place_name}/cinema/cinema-#{cinema_id}?date=#{date.strftime('%Y.%m.%d')}&geoPlaceID=#{place_id}&WidgetID=#{WIDGET_ID}"
	end

	def self.url_for_movies(start, length = PAGE_SIZE, place_id, place_name)
		# https://m.kassa.rambler.ru/spb/creation/topcreations/17?start=20&pagesize=10&WidgetID=16857&GeoPlaceID=3
		"#{DOMAIN}#{place_name}/creation/topcreations/17?start=#{start}&pagesize=#{length}&GeoPlaceID=#{place_id}&WidgetID=#{WIDGET_ID}"
	end

	def self.url_for_sessions(movie_id, date = nil, place_id, place_name)
		# https://m.kassa.rambler.ru/spb/movie/53046?date=2014.02.10&WidgetID=16857
		date = Time.now if date.nil?
		"#{DOMAIN}#{place_name}/movie/#{movie_id}?date=#{date.strftime("%Y.%m.%d")}&WidgetID=#{WIDGET_ID}"
	end

	def self.url_for_session(session_id, place_id)
		# http://m.kassa.rambler.ru/place/hallplan?sessionid=9637961&geoPlaceID=2&WidgetID=16857
		"#{DOMAIN}place/hallplan?sessionid=#{session_id}&geoPlaceID=#{place_id}&WidgetID=#{WIDGET_ID}"
	end

	def self.url_for_movie(movie_id)
		# https://kassa.rambler.ru/movie/45849
		"#{DOMAIN_DESKTOP}movie/#{movie_id}"
	end

	def self.fetch_session(session_id, place_id)
		fetch_data_html(url_for_session(session_id, place_id))
	end

	def self.fetch_movies(start, length = PAGE_SIZE, place_id, place_name)
		fetch_data_json(url_for_movies(start, length, place_id, place_name))
	end

	def self.fetch_cinemas(start, length = PAGE_SIZE, place_id, place_name)
		fetch_data_json(url_for_cinemas(start, length, place_id, place_name))
	end

	def self.fetch_cinema(cinema_id, date = nil, place_id, place_name)
		fetch_data_html(url_for_cinema(cinema_id, date, place_id, place_name))
	end

	def self.fetch_sessions(movie_id, date = nil, place_id, place_name)
		fetch_data_html(url_for_sessions(movie_id, date, place_id, place_name))
	end

	def self.fetch_movie(movie_id)
		fetch_data_html_no_headers(url_for_movie(movie_id))
	end

	#private_class_method :url_for_session
	private_class_method :url_for_sessions
	private_class_method :url_for_movies
	private_class_method :url_for_movie
	private_class_method :url_for_cinemas
	private_class_method :url_for_availability
	private_class_method :params_for_prices
	private_class_method :params_for_availability
	private_class_method :fetch_data_html
	private_class_method :fetch_data_json

	public_class_method :fetch_sessions
	public_class_method :fetch_cinemas
	public_class_method :fetch_movies
	public_class_method :fetch_movie
	public_class_method :fetch_session
	public_class_method :fetch_prices
	public_class_method :fetch_prices_full
end

