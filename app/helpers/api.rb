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

  def self.get_movie(city, id)
    url = "#{base_url}/#{city}/movies/#{id}"
    data = fetch_data(url)
    parse_movie(parse_json(data))
  end
end
