 def test_kinopoisk_imdb
	def check_parameter(field, sample, actual)
		if sample[field] != actual.send(field)
			puts ("'#{field}' field error (" + sample[field].to_s + " != " + actual.send(field).to_s + ")" ).red 
			return false
		end
		return true
	end

	retval = true
	begin
		# fixture
		m = Movie.new(
							:title => "Криминальное чтиво",
							:title_original => "Pulp Fiction",
							:year => 1994,
							:country => "США",
							:languages => "English, Spanish, French",
							:kinopoisk_id => 342,
							:imdb_id => 110912,
							:genres => "триллер, комедия, криминал",
							:duration => 154,
							:description => "Двое бандитов Винсент Вега и Джулс Винфилд проводят время в философских беседах",
							:description_english => "Jules Winnfield and Vincent Vega are two hitmen who are out to retrieve a suitcase stolen from their employer",
							:cast => "Джон Траволта, Сэмюэл Л. Джексон, Брюс Уиллис, Ума Турман, Винг Реймз, Тим Рот, Харви Кейтель, Квентин Тарантино, Питер Грин, Аманда Пламмер",
							:director => "Квентин Тарантино",
							:trailer => "mq9d2S4iJS0"
						)

		ids = movie_find_id(m.title)
		kr =  Kinopoisk.get_kinopoisk_rating ids[:kinopoisk]
		ir = Kinopoisk.get_imdb_rating ids[:imdb]
		k = KinopoiskParser::Movie.new ids[:kinopoisk]
		i = Imdb::Movie.new(ids[:imdb].to_s)
		c = Movie.new(
							:title => k.title,
							:title_original => k.title_en,
							:year => k.year,
							:country => k.countries.join(", "),
							:languages => i.languages.join(", "),
							:genres => k.genres.join(", "),
							:kinopoisk_id => ids[:kinopoisk],
							:imdb_id => ids[:imdb],
							:duration => k.length,
							:description => k.description,
							:description_english => i.plot_summary,
							:cast => k.actors.join(", "),
							:director => k.directors.join(", "),
							:trailer => movie_find_trailers(m.title)
						)

		r = Rating.new(
							:imdb_votes => ir[:votes],
							:imdb_rating => ir[:rating],
							:kinopoisk_votes => kr[:votes],
							:kinopoisk_rating => kr[:rating],
						)
		#partial comparison of descriptions
		c.description = c.description[0...15] rescue nil
		m.description = m.description[0...15] rescue nil
		c.description_english = c.description_english[0...15] rescue nil
		m.description_english = m.description_english[0...15] rescue nil

		result = []
		fields = [ 
					:cast, 
					:country,
					:description, 
					:description_english, 
					:duration, 
					:director, 
					:genres, 
					:imdb_id, 
					:kinopoisk_id, 
					:languages, 
					:title,
					:title_original, 
					:trailer,
					:year, 
				 ]
		fields.each {|f| result << check_parameter(f, m, c) }
		result << (r[:imdb_votes].to_i > 1000000)
		result << (r[:kinopoisk_votes].to_i > 100000)
		result << (r[:imdb_rating].to_f > 8.5)
		result << (r[:kinopoisk_rating].to_f > 8.2)
		
		unless result.include? false
			puts "[KP&IMDB] All tests passed".green unless result.include? false
		else
			puts "[KP&IMDB] Some tests failed".red
			retval = false
		end
	#rescue
	#	retval = false
	end
	retval
end

def test_kassa	
	def check_parameter(field, sample, actual)
		if sample[field] != actual.send(field)
			puts ("'#{field}' field error (" + sample[field].to_s + " != " + actual.send(field).to_s + ")" ).red 
			return false
		end
		return true
	end

	retval = true
	begin
		movies = [
					{ 	:id => 64245, 
						:title => "Мой дорогой", 
						:title_original => "Anata e",
						:country => "Япония",
						:year => 2012,
						:duration => 111,
						:age_restriction => 16,
						:genres => "драма",
						:poster => "https://img09.rl0.ru/kassa/c144x214/kassa.rambler.ru/s/StaticContent/Photos/140820170948/141107094642/p_O.jpg"
					},
					{ 	:id => 58529, 
						:title => "Зильс-Мария", 
						:title_original => "Clouds of Sils Maria",
						:country => "Франция, Швейцария, Германия",
						:year => 2014,
						:duration => 124,
						:age_restriction => 16,
						:genres => "драма",
						:poster => "https://img07.rl0.ru/kassa/c144x214/kassa.rambler.ru/s/StaticContent/Photos/140928164221/141003101349/p_O.jpg"
					},
					{ 	:id => 64265, 
						:title => "НОЧНОЙ НОН-СТОП:  Новая подружка, Рио, я люблю тебя, Одержимость", 
						:title_original => nil,
						:country => "Франция",
						:year => nil,
						:duration => 339,
						:age_restriction => 0,
						:genres => nil,
						:poster => "https://img05.rl0.ru/kassa/c144x214/kassa.rambler.ru/s/StaticContent/Photos/140402140149/141106123008/p_O.png"
					},
					{
						:id => 57690,
						:title => 'Детка',
						:title_original => 'Laggies',
						:genres => 'комедия, мелодрама',
						:country => 'США',
						:year => 2014,
						:duration => 97,
						:age_restriction => 16,
						:poster => 'https://img09.rl0.ru/kassa/c144x214/kassa.rambler.ru/s/StaticContent/Photos/140621235250/141024154934/p_O.jpg'
					}
				 ]
		result = []
		movies.each do |m|
			c = get_movie m[:id]
			result << check_parameter(:title, m, c)
			result << check_parameter(:title_original, m, c)
			result << check_parameter(:country, m, c)
			result << check_parameter(:year, m, c)
			result << check_parameter(:duration, m, c)
			result << check_parameter(:age_restriction, m, c)
			result << check_parameter(:genres, m, c)
			result << check_parameter(:poster, m, c)
		end

		unless result.include? false
			puts "[Kassa] All tests passed".green unless result.include? false
		else
			puts "[Kassa] Some tests failed".red
			retval = false
		end		
	#rescue
	#	retval = false
	end

	retval
end