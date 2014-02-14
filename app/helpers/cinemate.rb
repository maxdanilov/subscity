require 'hpricot'
require 'active_support/all'
require_relative 'logger'
require_relative 'parser_base'
require_relative 'fetcher_base'

class Cinemate
	extend FetcherBase
	extend ParserBase

	DOMAIN = 'http://cinemate.cc/'
	HOST = 'cinemate.cc'
	USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1700.102 Safari/537.36'
	
	HEADERS = 	{	
					"Connection" => "keep-alive",
					"Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
					"User-Agent" => USER_AGENT,
					"Referer" => DOMAIN,
					"Host" => HOST,
					"Cache-Control" => "max-age=0",
					"Accept-Encoding" => "gzip, deflate, sdch", #attention - if this field is set, content needs to be ungzipped!
					"Accept-Language" => "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4,de;q=0.2,fr;q=0.2" 
				}
	
	def self.fetch_data_html(url)
		fetch_data(url, HEADERS)
	end
	
	def self.equal_titles?(a,b)
		return false if a.nil? or b.nil?

		diff_size = ->(a, b) do
			similar = a.select { |el| b.include? el }
			a -= similar
			b -= similar
			(a + b).size
		end

		a, b = prepare_title(a), prepare_title(b)
		words_a, words_b = a.split(' '), b.split(' ')
		(a == b) or (diff_size.call(words_a,words_b) <= 1 and [words_a.size, words_b.size].min >= 2 )
	end

	# sometimes Kassa/Cinemate can add 3D/2D to the title, messing eveything up
	def self.prepare_title(title)
		title.gsub(/3D/,'').gsub(/2D/, '').gsub(/:/, '.').strip.mb_chars.downcase.to_s rescue title
	end

	# for special cases when Kassa fucks up titles so bad they can't be used for Cinemate search...
	def self.prepare_title_for_search(title)
		return "Нимфоманка. Часть 1" if (title == "Нимфоманка. Часть I")
		title
	end

	def self.get_csrf_token
		doc = Hpricot(fetch_data_html(DOMAIN))
		key = (doc/"form").at("input")[:value] rescue nil
	end

	def self.search_movie_url(csrf_token, name, year = nil)
		# http://cinemate.cc/search/?csrfmiddlewaretoken=zk2TWIm0jC4EsoRcu14Ma3GDbnh0Abgp&term=%D0%B2%D0%BE%D0%BB%D0%BA+%D1%81+%D1%83%D0%BE%D0%BB%D0%BB-%D1%81%D1%82%D1%80%D0%B8%D1%82
		url = DOMAIN + "search/?csrfmiddlewaretoken=" + csrf_token + "&term=" + name.to_s
		url += "+" + year.to_s unless year.nil?
		URI::encode(url)
	end

	def self.search_movie(csrf_token, name, year = nil)
		fetch_data_html(search_movie_url(name, csrf_token, year = nil))
	end

	def self.get_id_from_search(data)
		doc = Hpricot(data)
		id = (doc/"div.search_results_block").at("a")[:href] rescue nil
	end

	def self.get_movie_id(csrf_token, name, year = nil)
		url = get_id_from_search(search_movie(csrf_token, name, year))
		!url.nil? ? get_first_regex_match_integer(url, '/movie/(\d+)').to_i : nil
	end

	def self.url_for_id(id)
		DOMAIN + 'movie/' + id.to_s
	end

	def self.get_movie_page(id)
		fetch_data_html(url_for_id(id))
	end

	def self.parse_movie_page(data)
		doc = Hpricot(data)
		o = (doc/"#object_detail")
		# searching for thumbnail
		thumbnail = o.at("#object_photo/img")[:src] rescue nil
		#substitute big thumbnail for medium one
		thumbnail.gsub!(/big/, "medium") rescue nil

		text = o.at("#object_text") rescue nil
		divs = text.search("div.content") rescue nil
		divs_titles = text.search("div.title/strong") rescue nil
		
		# searching and looping through links in div, mapping to array which is joined into comma separated string
		inject_and_join = -> (div) { (div.search("a").inject([]) { |a, l| a << l.inner_text }).join(', ') }
		# "1 час. 57 мин." => 117
		parse_duration = -> (d) do
			t = d.split(' ')
			case t.size
				when 4 then t[0].to_i * 60 + t[2].to_i
				when 2 then t[1] =~ /м/ ? t[0].to_i : t[0].to_i * 60
				else 0
			end
		end

		div_with_title = -> (divs, text) do
			divs.each do |d|
				return (d.parent.parent.at(".content") rescue nil) if (d.inner_html rescue nil) =~ text
			end
		end

		div_regexps = 	{
							:genre => /Жанр/,
							:country => /Страна/,
							:director => /Режиссер/,
							:actors => /В ролях/,
							:description => /Описание/,
							:runtime => /Длительность/,
							:imdb => /IMDB/,
							:kinopoisk => /КиноПоиск/,
						}
		
		divs_titles = div_regexps.map {|k,v| {k => div_with_title.call(divs_titles, v) }}.reduce Hash.new, :merge rescue nil

		genres = inject_and_join.call(divs_titles[:genre]) rescue nil
		country = inject_and_join.call(divs_titles[:country])  rescue nil
		imdb_id = get_first_regex_match_integer( divs_titles[:imdb].at("a")[:href] , /(\d+)/ ) rescue nil
		kinopoisk_id = get_first_regex_match_integer( divs_titles[:kinopoisk].at("a")[:href] , /(\d+)/ ) rescue nil
		description = divs_titles[:description].inner_text.strip rescue nil
		director = inject_and_join.call(divs_titles[:director])  rescue nil
		actors = inject_and_join.call(divs_titles[:actors])  rescue nil
		runtime = parse_duration.call(divs_titles[:runtime].inner_text)  rescue nil

		name = doc.at("h2").inner_html.gsub(/<.*>/, "").strip rescue nil # greedy stripping tags, to get rid of annoying year in the name
		year = get_first_regex_match_integer(doc.at("h2").inner_text, /\((\d{4})\)/) rescue nil
		original_name = doc.at("h2/../small").inner_text rescue nil
		{
			title_russian: name,
			title_original: original_name,
			year: year,
			poster: thumbnail,
			genre: genres,
			country: country,
			imdb_id: imdb_id,
			kinopoisk_id: kinopoisk_id,
			description: description,
			runtime: runtime,
			director: director,
			cast: actors
		}

	end

	def self.get_and_parse_movie_page(id)
		parse_movie_page(get_movie_page(id))
	end

	private_class_method :fetch_data_html
	private_class_method :url_for_id
	private_class_method :search_movie
	private_class_method :search_movie_url
	private_class_method :get_id_from_search

	public_class_method :get_csrf_token
	public_class_method :get_movie_id
	public_class_method :get_movie_page
	public_class_method :parse_movie_page
	public_class_method :get_and_parse_movie_page

end

#key =  Cinemate.get_csrf_token
#puts Cinemate.get_movie_id("Выход через сувенирную лавку", key)
#puts Cinemate.get_movie_id("Future Shorts. Программа «Немного о любви»", key)
#puts Cinemate.parse_movie_page(File.read("wolf_c.htm"))
#puts Cinemate.parse_movie_page("")
#puts Cinemate.parse_movie_page(File.read("bleb.htm"))
#=begin
#puts Cinemate.get_and_parse_movie_page(601)
#puts
#puts Cinemate.get_and_parse_movie_page(8734)
#puts
#puts Cinemate.get_and_parse_movie_page(1661)
#=end