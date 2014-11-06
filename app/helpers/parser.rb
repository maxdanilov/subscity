require_relative 'parser_base'
require 'hpricot'
require 'time'

class KassaParser
	extend ParserBase

	HAS_SUBS = "субтитр"
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
				# looking up and aside in the DOM to find the cinema info
				session_cinema_id = get_cinema_id ( el.parent.preceding_siblings.filter("header").at("a")[:href] )
				session_cinema = Cinema.where(:cinema_id => session_cinema_id).first
				fetch_all = false
				fetch_all = session_cinema.fetch_all if session_cinema != nil			

				next if (not el.inner_html.include? HAS_SUBS) and (not fetch_all) 
														 # skip headlines of non-subs sessions
														 # but download all screenings for given cinemas

				# looking up and then down to find the sessions info
				el.parent.search("div/a").each do |a|
					session_id = get_session_id( a[:href] )
					session_time = parse_time( a.inner_html, date)
					# the night screenings are technically on the next day!
					session_time += 1.day if session_time.hour.between? 0, 5
					#p session_id.to_s + " " + session_time.to_s + " " + session_cinema_id.to_s
					session_movie = get_movie_id(a.parent.parent.parent.search("h3/a").first[:href]) rescue nil
					results << { session: session_id , time: session_time, cinema: session_cinema_id, movie: session_movie }
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
		title = (doc/"h1.item_title").first.inner_text rescue nil
		genres = (doc/"div.item_data__type").first.inner_text rescue nil
		title_original = (doc/"h2.item_title2").first.inner_text rescue nil

		extra_info = (doc/"div.item_data__years").first.inner_text.split(',') rescue []
		country = extra_info[0...-2].join(',').strip rescue nil
		year = extra_info[-2].strip rescue nil
		duration = extra_info[-1].split(' ')[0].to_i rescue nil
		age_restriction = extra_info[-1].split(' ')[2].to_i rescue nil

		poster = (doc/"div.item_img > img").first[:src] rescue nil
		poster = nil if poster =~ /empty/
		
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
		# for a different time zone: Time.parse(date.strftime("%Y-%m-%d") + " " + time + " +0400")
		Time.parse(date.strftime("%Y-%m-%d") + " " + time)
	end

	def self.screening_exists?(data)
		doc = Hpricot(data) rescue nil
		return false if doc.nil?
		((doc.at("title").inner_text rescue nil) =~ NOT_FOUND_SCREENING).nil?
	end

	def self.screening_title(data)
		doc = Hpricot(data) rescue nil
		return "" if doc.nil?
		title = doc.at("title").inner_text rescue ""
		title.split(TITLE_DELIMITER).first
	end

	def self.screening_date_time(data)
		#replace = ["сегодня", "завтра"]
		overnight = "в ночь с"
		months = ["янв", "фев", "мар", "апр", "ма", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"]		
		doc = Hpricot(data) rescue nil
		return nil if doc.nil?
		date_text = doc.at(".order-info dd:nth-of-type(2)").inner_text rescue ""
		tokens = date_text.split " "
		day = tokens[1]
		month_name = tokens[2]
		month = Time.now.month
		months.each_with_index do |m, i|
			next unless month_name.include? m
			month = i + 1
		end
		time = tokens[4]
		year = Time.now.year
		year += 1 if Time.now.month > month
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
