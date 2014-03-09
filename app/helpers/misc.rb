def price_tag_style(price)
	case price
		when 0...200 then "label-success"
		when 200...350 then "label-primary"
		when 350...500 then "label-warning"
		when 500...10**6 then "label-danger"
		else "label-danger"
	end
end

def age_restriction_style(age)
	case age
		when 0..12 then "label-success"
		when 13...16 then "label-info"
		when 16...18 then "label-warning"
		when 18...10**6 then "label-danger"
		else "label-success"
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

def format_word_count(count, words)
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
	count.to_s + " " + ret
end

def format_movies_count(count)
	format_word_count(count, {1 => "фильм", 2 => "фильма", 5 => "фильмов"})
end

def format_screenings_count(count)
	format_word_count(count, {1 => "сеанс", 2 => "сеанса", 5 => "сеансов"})
end

def format_cinemas_count(count)
	format_word_count(count, {1 => "кинотеатр", 2 => "кинотеатра", 5 => "кинотеатров"})
end

def format_date_url(date)
	#example: 2014-02-23
	date.strftime("%Y-%m-%d")
end

def link_to_cinema(cinema)
	link_to(cinema.name, "/cinemas/#{cinema.id}", :class => 'underdashed')
end

def link_to_movie(movie)
	link_to(movie.title, "/movies/#{movie.id}", :class => 'underdashed')
end

def link_to_date(date)	
	link_to(show_date(date), "/dates/#{date}", :class => 'underdashed')
end