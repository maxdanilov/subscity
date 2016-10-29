require_relative 'parser_base'
require 'nokogiri'
require 'time'

class KassaParser
	extend ParserBase

	HAS_SUBS = "языке оригинала"
	NOT_FOUND_SCREENING = /Сеанс не найден/
	TITLE_DELIMITER = " на языке оригинала"
	
	def self.parse_prices(data)
		parsed = parse_json(data)
		
		fee = 1.1 # Kassa's fee is 10% (if applied)
		min_price = 10 ** 9 # inf for poor people
		max_price = 0

		begin
			parsed["OrderZones"].each do |order_zone|
				order_zone["Orders"].each do |order|
					price = order["Price"]
					price = (price / fee).round(0) if order["HasFee"]
					max_price = price if price > max_price
					min_price = price if price < min_price
				end
			end
			max_price, min_price = max_price.to_i, min_price.to_i
			max_price, min_price = nil, nil if max_price == 0
			[max_price, min_price]
		rescue => e
			[nil, nil]
		end
	end

	def self.parse_prices_full(data)
		begin
			data = "<!DOCTYPE html><html>" + data + "</html>"
			doc = Nokogiri::XML.parse(data)
			max_price = min_price = nil
			prices = (doc/"div.b-cinema-plan/div[@data]").map { |el| el[:data].split('|')[3].to_i rescue nil }
			prices = prices.select {|x| x > 0}.compact.uniq.sort #occupied places have 0 price, kick them out before processing
			max_price, min_price = prices.last, prices.first
		rescue 
			[nil, nil]
		end
	end

	def self.parse_sessions_HTML(data, date, cinema_id = 0, movie_id = 0)
		doc = Nokogiri::XML.parse(data)
		results = []
		begin
			(doc/".heading").each do |el|
				# looking up and aside in the DOM to find the cinema info
				session_cinema_id = get_cinema_id ( el.at("a")[:href] )
				session_cinema_id = cinema_id.to_i if session_cinema_id.to_i == 0
				session_cinema = Cinema.where(:cinema_id => session_cinema_id).first

				fetch_all = false
				fetch_all = session_cinema.fetch_all unless session_cinema.nil?

				fetch_mode_movie = Movie.get_movie(movie_id).fetch_mode rescue FETCH_MODE[:movie][:subs]
				fetch_all = true if fetch_mode_movie == FETCH_MODE[:movie][:all]

				next if (not el.parent.parent.search(".caption").inner_text.include? HAS_SUBS) and (not fetch_all)
														 # skip headlines of non-subs sessions
														 # but download all screenings for given cinemas
				if fetch_all
					links = el.parent.parent.search('.sked a.sked_item') rescue []
				else
					el.parent.parent.search('.caption').each do |s|
						links = s.parent.search('a.sked_item') if s.inner_text.include? HAS_SUBS rescue []
					end
				end

				# looking up and then down to find the sessions info
				links.each do |a|
					session_id = get_session_id( a[:href] )
					session_time = parse_time( a.inner_html, date)
					# the night screenings are technically on the next day!
					session_time += 1.day if session_time.hour.between? 0, 5
					session_movie = get_movie_id( el.at("a")[:href] ) rescue nil					
					results << { session: session_id , time: session_time, cinema: session_cinema_id, movie: session_movie }
				end
			end
		#rescue => e
		#	nil
		end
		results
	end

	# Kassa genres => Kinopoisk genres
	def self.kinopoisk_genre(g)
		hash = {
				'боевики' => 'боевик',
				'вестерны' => 'вестерн',
				'военные фильмы' => 'военный',
				'детективные фильмы' => 'детектив',
				'дети' => 'детский',
				'детские фильмы' => 'детский',
				'документальное кино' => 'документальный',
				'драматические фильмы' => 'драма',
				'исторические фильмы' => 'история',
				'комедии' => 'комедия',
				'короткометражные фильмы' => 'короткометражный',
				'криминальные фильмы' => 'криминал',
				'мелодрамы' => 'мелодрама',
				'музыкальные фильмы' => 'музыка',
				'мультфильмы' => 'мультфильм',
				'мюзиклы' => 'мюзикл',
				'приключенческие фильмы' => 'приключения',
				'романтические комедии' => 'комедия, мелодрама',
				'семейное кино' => 'семейный',
				'спортивные фильмы' => 'спорт',
				'тв' => nil,
				'трагикомедии' => 'трагикомедия',
				'триллеры' => 'триллер',
				'фантастические фильмы' => 'фантастика',
				'фильмы ужасов' => 'ужасы',
				'фильмы-биографии' => 'биография',
				'экранизации классической литературы' => nil
			}

		# exclude years from genre list
		(1980..2030).each do |x|
			hash[x.to_s + ' г.'] = nil
		end

		return hash[g] if hash.has_key? g
		g
	end

	def self.parse_movie_HTML(data)
		doc = Nokogiri::XML.parse(data) rescue nil
		return nil if doc.nil?
		title = (doc/"h1.item_title").first.inner_text rescue nil
		genres = (doc/"h3.item_title3").first.inner_text.strip.split("\n")[0].strip rescue nil
		age_restriction = (doc/"h3.item_title3").first.inner_text.strip.split("\n")[1].strip.to_i rescue nil

		title_original = (doc/"h2.item_title2").first.inner_text.split("—")[0].strip rescue nil
		year = (doc/"h2.item_title2").first.inner_text.split("—")[1].strip rescue nil

		extra_info = (doc/"div.item_data__years").first.inner_text.split(',') rescue []
		country = extra_info[0..-2].select {|x| x.to_i == 0}.join(',').strip rescue nil
		duration = extra_info[-1].split(' ')[0].to_i rescue nil

		poster = (doc/"div.item_img > img").first[:src] rescue nil
		poster = nil if poster =~ /empty/

		country = nil if country.to_s.strip == '-'
		genres = genres.mb_chars.downcase.to_s unless genres.nil?
		title.strip! rescue nil
		title_original.strip! rescue nil
		year = nil if year.to_i == 0 or year.to_i < 1900
		duration = nil if duration.to_i > 1900

		unless genres.to_s.empty?
			genres_new = []
			genres.split(",").each { |g| genres_new << kinopoisk_genre(g.strip) }
			genres = genres_new.compact.join(", ")
		end

		genres = nil if genres.to_s.strip.empty?
		
		return nil if title == nil
		{   :title => title, 
			:title_original => title_original, 
			:genres => genres, 
			:country => country,
			:year => year,
			:duration => duration,
			:age_restriction => age_restriction,
			:poster => poster
		}
	end

	def self.parse_tickets_available?(data)
		parsed = parse_json(data) rescue nil
		unless parsed.nil?
			!(parsed["error"] == true or parsed["maxPlaceCount"] == 0)
		else
			false
		end
	end

	def self.parse_movie_dates(data)
		# https://m.kassa.rambler.ru/spb/movie/59237?date=2016.03.28&WidgetID=16857&geoPlaceID=3
		doc = Nokogiri::XML.parse(data)
		(doc/"option").map { |opt| Time.parse(get_first_regex_match(opt[:value], /date=([\d\.]+)/)) rescue Time.now.strip }
	end

	def self.get_session_id(link)
		# https://m.kassa.rambler.ru/spb/place/hallplan?sessionid=20977908&WidgetID=16857&geoPlaceID=3
		# => 20977908
		get_first_regex_match_integer(link, /sessionid=(\d+)/)
	end

	def self.get_movie_id(link)
		# https://m.kassa.rambler.ru/msk/movie/51945?geoplaceid=2&widgetid=16857
		# => 51945
		get_first_regex_match_integer(link, /movie\/(\d+)/)
	end

	def self.get_cinema_id(link)
		# https://m.kassa.rambler.ru/msk/cinema/kinoklub-fitil-2729?WidgetID=16857&geoPlaceID=2
		# => 2729
		get_first_regex_match_integer(link, /cinema\/.*\-(\d+)/)
	end

	def self.parse_time(time, date)
		# 11:10 => given date at 11:10
		# for a different time zone: Time.parse(date.strftime("%Y-%m-%d") + " " + time + " +0400")
		Time.parse(date.strftime("%Y-%m-%d") + " " + time)
	end

	def self.screening_exists?(data)
		doc = Nokogiri::XML.parse(data) rescue nil
		return false if doc.nil?
		((doc.at("title").inner_text rescue nil) =~ NOT_FOUND_SCREENING).nil?
	end

	def self.screening_has_subs?(data)
		doc = Nokogiri::XML.parse(data) rescue nil
		return false if doc.nil?
		title = doc.at("title").inner_text rescue ""
		title.include? HAS_SUBS
	end

	def self.screening_title(data)
		doc = Nokogiri::XML.parse(data) rescue nil
		return "" if doc.nil?
		title = doc.at("title").inner_text rescue ""
		title.split(TITLE_DELIMITER).first
	end

	def self.screening_date_time(data)
		replace = ["сегодня", "завтра"]
		overnight = "в ночь с"
		months = ["янв", "фев", "мар", "апр", "май", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"]
		doc = Nokogiri::XML.parse(data) rescue nil
		return nil if doc.nil?
		date_text = doc.at(".order-info dd:nth-of-type(3)").inner_text rescue ""
		tokens = date_text.split " "
		day = tokens[1]
		month_name = tokens[2]
		month = Time.now.month
		months.each_with_index do |m, i|
			next unless month_name.include? m rescue nil
			month = i + 1
		end
		time = tokens[4]
		year = Time.now.year
		year += 1 if Time.now.month < month and month == 12
		date = Time.local(year, month, day, 0, 0, 0)
		date += 1.day if date_text.include? overnight
		parse_time(time, date)
	end

	private_class_method	:parse_time
	private_class_method	:get_cinema_id
	private_class_method	:get_session_id

	public_class_method		:parse_prices
	public_class_method		:parse_sessions_HTML
	public_class_method		:screening_exists?
	public_class_method		:parse_tickets_available?
	public_class_method		:parse_movie_dates
end
