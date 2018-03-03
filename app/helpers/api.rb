require 'ostruct'

class Api
  extend ApiBase

  def self.get_city(domain)
    case domain
    when 'msk'
      OpenStruct.new(domain: domain, name: 'Москва', name_short: 'Москва')
    when 'spb'
      OpenStruct.new(domain: domain, name: 'Санкт-Петербург', name_short: 'СПб')
    end
  end

  def self.parse_movie(json_data, language = 'ru')
    movie = OpenStruct.new
    movie.title = json_data['title'][language]
    movie.title_original = json_data['title']['en']
    movie.description = json_data['description'][language]
    movie.description_formatted = movie.description&.gsub("\n", '<br>')
    movie.cast = json_data['cast'][language]&.join(', ')
    movie.director = json_data['directors'][language]&.join(', ')
    movie.genres = json_data['genres'][language]&.join(', ')
    movie.duration = json_data['duration']
    movie.country = json_data['countries'][language]&.join(', ')
    movie.language = json_data['languages'][language]&.join(', ')
    movie.year = json_data['year']
    movie.next_screening = json_data['stats']['next_screening']
    movie.screening_count = json_data['stats']['screenings']
    movie.cinema_count = json_data['stats']['cinemas']
    movie
  end

  def self.parse_screening(json_data)
    screening = OpenStruct.new
    screening.date_time = parse_date_time(json_data['date_time'])
    screening.day = date_for_screening(screening.date_time).to_date.to_s
    screening.cinema_id = json_data['cinema_id']
    screening.movie_id = json_data['movie_id']
    screening.price_min = screening.price_max = json_data['price']&.to_i
    screening
  end

  def self.parse_movie_screenings(json_data)
    screenings = json_data&.map { |s| parse_screening(s) }
    by_days = screenings.group_by(&:day)
    by_days_and_cinemas = by_days.map { |k, v| { k => v.group_by(&:cinema_id) } }
    by_days_and_cinemas.reduce({}, :merge).sort.to_h # hash, grouped by days and then by cinemas
  end

  def self.parse_cinema(json_data, language = 'ru')
    cinema = OpenStruct.new
    cinema.name = json_data['name'][language]
    cinema.id = json_data['id']
    cinema.metro = json_data['location']['metro'][language]&.join(', ')
    cinema.formatted_url = "#{cinema.id} #{Translit.convert(cinema.name, :english)}".to_url
    cinema
  end

  def self.parse_cinemas(json_data, language = 'ru')
    json_data&.map { |c| parse_cinema(c, language) }
  end

  def self.get_movie_screenings(city, id)
    url = "#{base_url}/#{city}/screenings/movie/#{id}"
    data = fetch_data(url)
    parse_movie_screenings(parse_json(data))
  end

  def self.get_movie(city, id)
    url = "#{base_url}/#{city}/movies/#{id}"
    data = fetch_data(url)
    parse_movie(parse_json(data))
  end

  def self.get_cinemas(city)
    url = "#{base_url}/#{city}/cinemas"
    data = fetch_data(url)
    parse_cinemas(parse_json(data))
  end
end
