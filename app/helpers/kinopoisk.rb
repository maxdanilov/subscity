require 'open-uri'
require 'nokogiri'
require 'timeout'

class Kinopoisk
  def self.fetch_rating_xml(id)
    # http://rating.kinopoisk.ru/535244.xml
    # for some reason, open's :read_timeout won't work:
    Timeout.timeout(5) do
      open("https://rating.kinopoisk.ru/#{id}.xml").read
    end
  rescue
    nil
  end

  def self.get_imdb_rating(imdb_id)
    url = "https://www.imdb.com/title/tt#{imdb_id.to_s.rjust(8, '0')}/"
    error = false
    rating, votes = nil
    begin
      # for some reason, open's :read_timeout won't work:
      Timeout.timeout(5) do
        doc = Nokogiri::XML.parse(open(url))
        rating = doc.at('[@itemprop=ratingValue]').inner_text.to_f rescue nil
        votes = doc.at('[@itemprop=ratingCount]').inner_text.gsub(/[^0-9]/, '').to_i rescue nil
      end
    rescue
      rating, votes = nil
      error = true
    end
    { error: error, rating: rating, votes: votes }
  end

  def self.get_kinopoisk_rating(kinopoisk_id)
    data = Kinopoisk.fetch_rating_xml(kinopoisk_id)
    error = false
    begin
      doc = Nokogiri::XML(data)
      rating = doc.at('kp_rating').inner_text.to_f
      votes = doc.at('kp_rating')['num_vote'].to_i
    rescue
      rating, votes = nil
      error = true
    end
    { error: error, rating: rating, votes: votes }
  end

  def self.get_ratings(kinopoisk_id, imdb_id)
    kp = kinopoisk_id.to_i.zero? ? { error: false } : get_kinopoisk_rating(kinopoisk_id) rescue nil
    imdb = imdb_id.to_i.zero? ? { error: false } : get_imdb_rating(imdb_id) rescue nil
    kinopoisk_rating = kp[:rating] rescue nil
    kinopoisk_votes = kp[:votes] rescue nil
    imdb_rating = imdb[:rating] rescue nil
    imdb_votes = imdb[:votes] rescue nil

    { kinopoisk: { rating: kinopoisk_rating, votes: kinopoisk_votes },
      imdb: { rating: imdb_rating, votes: imdb_votes } }
  end

  def self.update_ratings(movie)
    puts "\tUpdating rating #{movie.kinopoisk_id}..."
    result = Kinopoisk.get_ratings(movie.kinopoisk_id, movie.imdb_id) rescue nil

    if result.nil?
      puts "\t\t An error occured for #{movie.kinopoisk_id}..."
    else
      r = nil
      if Rating.exists?(movie_id: movie.movie_id)
        puts "\t\t Updating a record..."
        r = Rating.where(movie_id: movie.movie_id).first
      else
        puts "\t\t Creating a record..."
        r = Rating.new(movie_id: movie.movie_id)
      end

      unless result[:kinopoisk][:rating].nil?
        r[:kinopoisk_rating] = result[:kinopoisk][:rating].to_f
        r[:kinopoisk_votes] = result[:kinopoisk][:votes].to_i
      end

      unless result[:imdb][:rating].nil?
        r[:imdb_rating] = result[:imdb][:rating].to_f
        r[:imdb_votes] = result[:imdb][:votes].to_i
      end

      r.save
      puts "\t\t Update result: #{result}..."
    end
  end

  def self.poster_url(movie)
    movie.kinopoisk_id.nil? ? '' : "http://st.kp.yandex.net/images/film_iphone/iphone360_#{c.kinopoisk_id}.jpg"
  end
end
