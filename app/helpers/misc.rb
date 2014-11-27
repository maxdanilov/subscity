def price_tag_style(price)
	case price
		when 0...200 then "label-success"
		when 200...350 then "label-primary"
		when 350...500 then "label-warning"
		when 500...10**6 then "label-danger"
		else "label-danger"
	end
end

def time_of_day(time)
	case time.hour
		when 6...12 then "morning"
		when 12...18 then "day"
		else "evening"
	end
end

def format_price(price)
	unless price.to_s.empty?
		price.to_s + " р."
	else
		"."
	end
end

def format_price_range(min, max)
	if min.to_i != max.to_i
		"от #{min.to_i} до #{max.to_i} руб."
	else
		"#{min.to_i} руб."
	end
end

def format_title(title)
	title#.to_s.split("/").first.to_s.strip
end

def format_word(count, words)
	unless count.to_i.between? 11, 14
		case count.to_i % 10
			when 1 then ret = words[1]
			when 2..4 then ret = words[2]
			when 5..9 then ret = words[5]
			else ret = words[5]
		end
	else
		ret = words[5]
	end
	ret
end

def format_word_count(count, words)
	count.to_s + " " + format_word(count, words)
end

def languages_format(langs)
	langs.split(", ").uniq.map {|l| language(l)}.join(", ") rescue nil
end

def language(lang)
	l = {
			'English' => 'английский',
			'Aboriginal' => 'аборигенский',
			'Arabic' => 'арабский',
			'Afrikaans' => 'африкаанс',
			'Bulgarian' => 'болгарский',
			'Catalan' => 'каталанский',
			'Chinese' => 'китайский',
			'Croatian' => 'хорватский',
			'Creole' => 'креольский',
			'Czech' => 'чешский',
			'Danish' => 'датский',
			'Dutch' => 'голландский',
			'Estonian' => 'эстонский',
			'Faroese' => 'фарерский',
			'Finnish' => 'финский',
			'French' => 'французский',
			'German' => 'немецкий',
			'Greek' => 'греческий',
			'Greenlandic' => 'гренландский',
			'Hebrew' => 'иврит',
			'Hindi' => 'хинди',
			'Hungarian' => 'венгерский',
			'Icelandic' => 'исландский',
			'Irish' => 'ирландский',
			'Irish Gaelic' => 'ирландский',
			'Italian' => 'итальянский',
			'Japanese' => 'японский',
			'Korean' => 'корейский',
			'Latvian' => 'латышский',
			'Ladino' => 'ладино',
			'Lithuanian' => 'литовский',
			'Luxembourgish' => 'люксембуржский',
			'Macedonian' => 'македонский',
			'Mandarin' => 'китайский',
			'Navajo' => 'навахо',
			'Norwegian' => 'норвежский',
			'Polish' => 'польский',
			'Portuguese' => 'португальский',
			'Romanian' => 'румынский',
			'Russian' => 'русский',
			'Scottish' => 'шотландский',
			'Serbian' => 'сербский',
			'Slovenian' => 'словенский',
			'Slovakian' => 'словацкий',
			'Somali' => 'сомалийский',
			'Spanish' => 'испанский',
			'Swahili' => 'суахили',
			'Swedish' => 'шведский',
			'Swiss German' => 'немецкий (швейцарский диалект)',
			'Telugu' => 'телугу',
			'Turkish' => 'турецкий',
			'Urdu' => 'урду',
			'Ukrainian' => 'украинский',
			'Welsh' => 'уэльский',
			'Wolof' => 'волоф',
			'Yiddish' => 'идиш'
		}
	
	l[lang] || lang
end

def format_word_count_generic(count, with_number, words)
	if with_number
		format_word_count(count, words)
	else
		format_word(count, words)
	end
end

def format_next_screening(time)
	date = date_for_screening(time)
	date_now = date_for_screening(Time.now)
	diff = difference_in_days(date, date_now)
	case diff
		when 0
			'сегодня'
		when 1
			'завтра'
		when 2
			'послезавтра'
		else
			"через #{format_in_days_count(diff)}"
	end
end

def format_in_days_count(count, with_number = true)
	format_word_count_generic(count, with_number, {1 => "день", 2 => "дня", 5 => "дней"})
end

def format_movies_count(count, with_number = true)
	format_word_count_generic(count, with_number, {1 => "фильм", 2 => "фильма", 5 => "фильмов"})
end

def format_screenings_count(count, with_number = true)
	format_word_count_generic(count, with_number, {1 => "сеанс", 2 => "сеанса", 5 => "сеансов"})
end

def format_cinemas_count(count, with_number = true)
	format_word_count_generic(count, with_number, {1 => "кинотеатр", 2 => "кинотеатра", 5 => "кинотеатров"})
end

def format_in_cinemas_count(count, with_number = true)
	format_word_count_generic(count, with_number, {1 => "кинотеатре", 2 => "кинотеатрах", 5 => "кинотеатрах"})
end

def format_date_url(date)
	#example: 2014-02-23
	date.strftime("%Y-%m-%d")
end

def format_movie_url(m)
	"#{m.id.to_s} #{Translit.convert(m.title, :english)}".to_url
end

def format_cinema_url(m)
	"#{m.id.to_s} #{Translit.convert(m.name, :english)}".to_url
end

def format_simple_url(m)
	m.id.to_s
end

def link_to_cinema(cinema)
	link_to(cinema.name, url(:cinemas, :index, cinema.format_url), :class => 'underdashed')
end

def link_to_movie(movie, text = nil)
	#link_to(hyphenate(movie.title, :ru), url(:movies, movie.format_url), :class => 'underdashed')
	text ||= movie.title
	"<a class='underdashed' href='#{url(:movies, :index, movie.format_url)}'>#{hyphenate(text, :ru)}</a>"
end

def link_to_date(day)	
	link_to(show_date(day), url(:dates, :index, day), :class => 'underdashed')
end

def hyphenate(text, lang)
	h = Text::Hyphen.new(:language => lang.to_s, :left => 4, :right => 4)
	text.split(" ").collect! { |w| h.visualise(w, "&shy;") }.join(" ")
end

class String
	def is_russian?
		letters = ('а'..'я').to_a + ('А'..'Я').to_a
		letters.each { |l| return true if self.include? l }
		false
	end
end