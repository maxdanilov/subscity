require_relative 'parser_base'
require 'nokogiri'
require 'time'

class KassaParser
  extend ParserBase

  HAS_SUBS = 'языке оригинала'.freeze
  HAS_SUBS_TYPE = 'russiansubtitles'.freeze
  NOT_FOUND_SCREENING = /Сеанс не найден/
  TITLE_DELIMITER = ' на языке оригинала'.freeze

  def self.parse_cinema_sessions(data, cinema_id)
    results = []
    return results unless data
    entity = JSON.parse(data) rescue nil
    return results if !entity || !entity['creations']

    entity['creations'].each do |movie|
      (movie['sessions'] || []).each do |screening|
        next unless (screening['formats'] || []).include? HAS_SUBS_TYPE
        results << { session: screening['id'],
                     time: parse_date_time(screening['startDateTime']),
                     cinema: cinema_id,
                     movie: movie['id'] }
        # TODO: prices can be parsed as well
      end
    end
    results
  end

  def self.parse_movie_sessions(data, movie_id)
    results = []
    return results unless data
    entity = JSON.parse(data) rescue nil
    return results if !entity || !entity['buckets']

    entity['buckets'].each do |cinemas|
      cinemas['places'].each do |cinema|
        cinema['sessions'].each do |screening|
          next unless (screening['formats'] || []).include? HAS_SUBS_TYPE
          results << { session: screening['id'],
                       time: parse_date_time(screening['startDateTime']),
                       cinema: cinema['id'],
                       movie: movie_id,
                       price: screening['minPrice'] }
        end
      end
    end
    results
  end

  def self.parse_movie_genres(doc)
    genres = (doc / 'h3.item_title3').first.inner_text.strip.lines[0].strip.chomp(',') rescue nil
    genres = genres.mb_chars.downcase.to_s.strip unless genres.nil?
    genres.to_s.empty? ? nil : genres
  end

  def self.parse_movie_title(doc)
    (doc / 'h1.item_title').first.inner_text.strip rescue nil
  end

  def self.parse_movie_title_original(doc)
    (doc / 'h2.item_title2').first.inner_text.split('—')[0].strip rescue nil
  end

  def self.parse_movie_age_restriction(doc)
    (doc / 'h3.item_title3').first.inner_text.strip.lines[-1].strip.to_i rescue nil
  end

  def self.parse_movie_year(doc)
    year = (doc / 'h2.item_title2').first.inner_text.strip.lines[-1].to_i rescue nil
    year.to_i.zero? || year.to_i < 1900 ? nil : year
  end

  def self.parse_movie_poster(doc)
    poster = (doc / 'div.item_img > img').first[:src] rescue nil
    poster =~ /empty/ ? nil : poster
  end

  def self.parse_movie_duration(doc)
    duration = doc.css('span.dd')[0].inner_text.split(' ')[0].to_i rescue nil
    duration.to_i > 1900 ? nil : duration
  end

  def self.parse_movie_country(doc)
    country = doc.css('span.dd')[1].inner_text.strip rescue nil
    country.to_s.strip == '-' ? nil : country
  end

  def self.parse_movie_director(doc)
    doc.css('span.dd[itemprop=name]').first.inner_text.strip rescue nil
  end

  def self.parse_movie_actors(doc)
    (doc / 'span.item_peop__actors').first.inner_text.strip rescue nil
  end

  def self.parse_movie_description(doc)
    (doc / 'span.item_desc__text-full').first.inner_text.strip rescue nil
  end

  def self.parse_movie_html(data)
    doc = Nokogiri::XML.parse(data) rescue nil
    return nil if doc.nil?

    title = parse_movie_title(doc)
    return nil if title.nil?

    {
      actors: parse_movie_actors(doc),
      age_restriction: parse_movie_age_restriction(doc),
      country: parse_movie_country(doc),
      description: parse_movie_description(doc),
      director: parse_movie_director(doc),
      duration: parse_movie_duration(doc),
      genres: parse_movie_genres(doc),
      poster: parse_movie_poster(doc),
      title: title,
      title_original: parse_movie_title_original(doc),
      year: parse_movie_year(doc)
    }
  end

  def self.parse_movie_dates(data)
    # https://m.kassa.rambler.ru/spb/movie/59237?date=2016.03.28&WidgetID=16857&geoPlaceID=3
    doc = Nokogiri::XML.parse(data)
    (doc / 'option').map { |o| Time.parse(get_first_regex_match(o[:value], /date=([\d\.]+)/)) rescue Time.now.strip }
  end

  def self.get_session_id(link)
    # https://w.kassa.rambler.ru/event/33040795/340fc69e-10f4-423e-a19c-1a5fd3ca94b6/http%3a%2f%2fm.kassa.rambler.ru%2fmsk%2fmovie%2f66499/
    # => 33040795
    get_first_regex_match_integer(link, %r{event\/(\d+)})
  end

  def self.get_movie_id(link)
    # https://m.kassa.rambler.ru/msk/movie/51945?geoplaceid=2&widgetid=16857
    # => 51945
    get_first_regex_match_integer(link, %r{movie\/(\d+)})
  end

  def self.get_cinema_id(link)
    # https://m.kassa.rambler.ru/msk/cinema/kinoklub-fitil-2729?WidgetID=16857&geoPlaceID=2
    # => 2729
    get_first_regex_match_integer(link, %r{cinema\/.*\-(\d+)})
  end

  def self.parse_date_time(datetime)
    Time.parse(datetime)
  end

  def self.parse_time(time, date)
    # 11:10 => given date at 11:10
    # for a different time zone: Time.parse(date.strftime("%Y-%m-%d") + " " + time + " +0400")
    Time.parse(date.strftime('%Y-%m-%d') + ' ' + time)
  end

  def self.screening_exists?(data)
    entity = JSON.parse(data) rescue nil
    entity && !entity['creation'].nil?
  end

  def self.screening_has_subs?(data)
    entity = JSON.parse(data) rescue nil
    ((entity || {})['formats'] || []).include? HAS_SUBS_TYPE
  end

  def self.screening_movie_id(data)
    entity = JSON.parse(data) rescue nil
    entity['creation']['id'] rescue nil
  end

  def self.screening_date_time(data)
    entity = JSON.parse(data) rescue nil
    parse_date_time(entity['startDateTime']) rescue nil
  end

  def self.parse_prices(data)
    entity = JSON.parse(data) rescue nil
    min_price = entity['levels'][0]['seatTypes'].map { |_, v| v['price'] }.min rescue nil
    max_price = entity['levels'][0]['seatTypes'].map { |_, v| v['price'] }.max rescue nil
    [min_price, max_price]
  end

  private_class_method	:parse_time
  private_class_method	:get_cinema_id
  private_class_method	:get_session_id

  public_class_method		:parse_prices
  public_class_method		:screening_exists?
  public_class_method		:parse_movie_dates
end
