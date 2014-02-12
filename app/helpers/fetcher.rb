require_relative 'fetcher_base'

class KassaFetcher
	extend FetcherBase

	DOMAIN = "http://m.kassa.rambler.ru/"
	HOST = "m.kassa.rambler.ru"
	USER_AGENT = "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.102 Safari/537.36"
	WIDGET_ID = 16857
	
	PAGE_SIZE = 20
	CITY_ID = 2
	URL_FOR_PRICES = 'http://m.kassa.rambler.ru/place/hallplanajax'

	JSON_HEADERS =	   {	"Connection" => "keep-alive",
							"Accept" => "*/*",
							"X-Requested-With" => "XMLHttpRequest",
							"User-Agent" => USER_AGENT,
							"Referer" => DOMAIN,
							"Host" => HOST,
							"Accept-Encoding" => "gzip,deflate,sdch",
							"Accept-Language" => "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2" }
	
	STANDARD_HEADERS = {	
							"Connection" => "keep-alive",
							"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
							"User-Agent" => USER_AGENT,
							"Referer" => DOMAIN,
							"Host" => HOST,
							"Cache-Control" => "max-age=0",
							"Accept-Encoding" => "gzip, deflate, sdch", #attention - if this field is set, content needs to be ungzipped!
							"Accept-Language" => "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2" 
						}

	def self.fetch_data_json(url)
		fetch_data(url, JSON_HEADERS)
	end

	def self.fetch_data_html(url)
		fetch_data(url, STANDARD_HEADERS)
	end

	def self.fetch_prices(screening_id)
		fetch_data_post(URL_FOR_PRICES, params_for_prices(screening_id))
	end

	def self.params_for_prices(screening_id)
		{ 'sessionID' => screening_id, 'placeCount' => 1, 'widgetID' => WIDGET_ID }
	end
	
	def self.url_for_cinemas(start, length = PAGE_SIZE, placeid = CITY_ID)
		# http://m.kassa.rambler.ru/place/nearplaces/cinema?start=0&pagesize=20&geoplaceid=2&widgetid=16857
		DOMAIN + "place/nearplaces/cinema?start=" + start.to_s + "&pagesize=" + length.to_s + "&geoplaceid=" + placeid.to_s + "&widgetid=" + WIDGET_ID.to_s
	end
	
	def self.url_for_movies(start, length = PAGE_SIZE, placeid = CITY_ID)
	    # http://m.kassa.rambler.ru/creation/topcreations/17?start=0&pagesize=20&geoplaceid=2&widgetid=16857
		DOMAIN + "creation/topcreations/17?start=" + start.to_s + "&pagesize=" + length.to_s + "&geoplaceid=" + placeid.to_s + "&widgetid=" + WIDGET_ID.to_s
	end

	def self.url_for_sessions(movie_id, date = nil, place_id = CITY_ID)
		# http://m.kassa.rambler.ru/movie/53046?geoplaceid=2&widgetid=16857
		# http://m.kassa.rambler.ru/movie/53046?date=2014.02.10&geoPlaceID=2&widgetid=16857
		date = Time.now if date.nil?
		DOMAIN + "movie/" + movie_id.to_s + "?date=" + date.strftime("%Y.%m.%d") + "&geoplaceid=" + place_id.to_s + "&widgetid=" + WIDGET_ID.to_s
	end

	def self.url_for_session(session_id, place_id = CITY_ID)
	#http://m.kassa.rambler.ru/place/hallplan?sessionid=9637961&geoPlaceID=2&widgetid=16857
		DOMAIN + "place/hallplan?sessionid=" + session_id.to_s + "&geoPlaceID=" + place_id.to_s + "&widgetid=" + WIDGET_ID.to_s
	end

	def self.fetch_session(session_id, place_id = CITY_ID)
		fetch_data_html(url_for_session(session_id, place_id))
	end

	def self.fetch_movies(start, length = PAGE_SIZE, place_id = CITY_ID)
		fetch_data_json(url_for_movies(start, length, place_id))
	end
	
	def self.fetch_cinemas(start, length = PAGE_SIZE, place_id = CITY_ID)
		fetch_data_json(url_for_cinemas(start, length, place_id))
	end

	def self.fetch_sessions(movie_id, date = nil, place_id = CITY_ID)
		fetch_data_html(url_for_sessions(movie_id, date, place_id))
	end

	private_class_method :url_for_session
	private_class_method :url_for_sessions
	private_class_method :url_for_movies
	private_class_method :url_for_cinemas
	private_class_method :url_for_session
	private_class_method :params_for_prices
	private_class_method :fetch_data_html
	private_class_method :fetch_data_json

	public_class_method :fetch_sessions
	public_class_method :fetch_cinemas
	public_class_method :fetch_movies
	public_class_method :fetch_session
	public_class_method :fetch_prices
end