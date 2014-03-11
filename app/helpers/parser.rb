require_relative 'parser_base'
require 'hpricot'
require 'time'

class KassaParser
	extend ParserBase

	HAS_SUBS = "субтитр"
	NOT_FOUND_SCREENING = /Сеанс не найден/
	
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
		rescue Exception => e
			[nil, nil]
		end
	end

	def self.parse_prices_full(data)
		begin
			doc = Hpricot(data)
			max_price = min_price = nil
			prices = (doc/"div.b-cinema-plan/div[@data]").map { |el| el[:data].split('|')[3].to_i rescue nil }
			prices = prices.select {|x| x > 0}.compact.uniq.sort #occupied places have 0 price, kick them out before processing
			max_price, min_price = prices.last, prices.first
		rescue 
			[nil, nil]
		end
	end

	def self.parse_sessions_HTML(data, date)
		doc = Hpricot(data)
		results = []
		begin
			(doc/"p.caption").each do |el|
				next if !el.inner_html.include? HAS_SUBS # skip headlines of non-subs sessions

				# looking up and aside in the DOM to find the cinema info
				session_cinema = get_cinema_id ( el.parent.preceding_siblings.filter("header").at("a")[:href] )
				# looking up and then down to find the sessions info
				el.parent.search("div/a").each do |a|
					session_id = get_session_id( a[:href] )
					session_time = parse_time( a.inner_html, date)
					# the night screenings are technically on the next day!
					session_time += 1.day if session_time.hour.between? 0, 5
					#p session_id.to_s + " " + session_time.to_s + " " + session_cinema.to_s
					session_movie = get_movie_id(a.parent.parent.parent.search("h3/a").first[:href]) rescue nil
					results << { session: session_id , time: session_time, cinema: session_cinema, movie: session_movie }
				end
			end
		rescue Exception => e
			nil
		end
		results
	end

	def self.parse_movie_HTML(data)
		doc = Hpricot(data) rescue nil
		return nil if doc.nil?
		title = (doc/"div.primary-col > h1[@itemprop='name']").first.inner_text rescue nil
		genres = (doc/"div.primary-col > div").first.inner_text rescue nil
		title_original = (doc/"div.primary-col > p:not(.event-header_type)").first.inner_text rescue nil
		title_original = nil if (doc/"div.primary-col > p:not(.event-header_type)").first.search("span").length > 0
		#title_original = (doc/"h1[@itemprop='name'] ~ p:not(.event-header_type):empty").first.inner_text rescue nil
		country = (doc/"div.primary-col > p:not(.event-header_type) span:nth-child(1)").inner_text[0...-1] rescue nil
		year = (doc/"div.primary-col > p:not(.event-header_type) span:nth-child(2)").inner_text.to_i rescue nil
		duration = (doc/"div.primary-col > p:not(.event-header_type) span:nth-child(3)").inner_text.to_i rescue nil
		age_restriction = (doc/"div.primary-col > p:not(.event-header_type) b").inner_text.to_i rescue nil
		poster = (doc/"div.pull-right > img").first[:src] rescue nil
		
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
		# http://m.kassa.rambler.ru/movie/53046?date=2014.02.16&geoPlaceID=2&widgetid=16857
		doc = Hpricot(data)
		(doc/"option").map { |opt| Time.parse(get_first_regex_match(opt[:value], /date=([\d\.]+)/)) rescue Time.now.strip }
	end

	def self.get_session_id(link)
		#http://m.kassa.rambler.ru/place/hallplan?sessionid=9637961&geoPlaceID=2&widgetid=16857
		# => 9637961
		get_first_regex_match_integer(link, /sessionid=(\d+)/)
	end

	def self.get_movie_id(link)
		#http://m.kassa.rambler.ru/movie/51945?geoplaceid=2&widgetid=16857
		# => 51945
		get_first_regex_match_integer(link, /movie\/(\d+)/)
	end

	def self.get_cinema_id(link)
		# http://m.kassa.rambler.ru/place/2729?geoPlaceID=2&widgetid=16857
		# => 2729
		get_first_regex_match_integer(link, /place\/(\d+)/)
	end

	def self.parse_time(time, date)
		# 11:10 => given date at 11:10
		Time.parse(date.strftime("%Y-%m-%d") + " " + time)
	end

	def self.screening_exists?(data)
		doc = Hpricot(data) rescue nil
		return false if doc.nil?
		((doc.at("title").inner_text rescue nil) =~ NOT_FOUND_SCREENING).nil?
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
