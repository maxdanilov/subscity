class Movie < ActiveRecord::Base
  has_many :screenings, primary_key: 'movie_id'
  has_many :cinemas, through: :screenings, primary_key: 'movie_id'
  has_one :rating, primary_key: 'movie_id'

  validates :title, presence: true
  validates :movie_id, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  def format_url
    @format_url ||= format_movie_url(self)
  end

  def description?
    @has_descr ||= !any_description.to_s.empty?
  end

  def any_description
    @get_descr ||= (description || description_english).to_s
  end

  def description_formatted
    @get_descr_f ||= any_description.gsub("\r\n", "\n").gsub("\n\n", '<br/>').gsub("\n", '<br/>')
  end

  def valid_genre?
    return true if genres.nil?

    non_valid_genres = %w[опера балет фильмы-спектакли оперетты фильм-спектакль]
    !(non_valid_genres.any? { |w| genres.include? w })
  end

  def night_nonstop?
    title.mb_chars.downcase.to_s.strip.start_with? 'ночной нон-стоп'
  end

  def russian?
    return true if %w[Россия СССР].include? country
    return true if %w[Russian русский].include? languages

    false
  end

  def old?
    return true if year.to_i != 0 && year.to_i < 1980

    false
  end

  def hidden?
    hide || (night_nonstop? && !SETTINGS[:movie_show_night_nonstops])
  end

  def in_db?
    !Movie.where("movie_id = #{movie_id}").empty?
  end

  def self.are_equal?(first, second)
    prepare_title = ->(title) { title.mb_chars.downcase.to_s.gsub('(16+)', '').gsub('(18+)', '').strip }
    prepare_title.call(first.title) == prepare_title.call(second.title)
  end

  def self.get_movie(id)
    Movie.where("movie_id = #{id}").first
  end

  def get_screenings(city_id)
    screenings.active.in_city(city_id).order(:date_time)
  end

  def get_screenings_all(city_id)
    screenings.active_all.in_city(city_id).order(:date_time)
  end

  def get_next_screening(city_id)
    get_screenings(city_id).first
  end

  def get_sorted_screenings(city_id, active_all = false)
    screenings_all = if active_all
                       get_screenings_all(city_id)
                     else
                       get_screenings(city_id)
                     end
    cinemas_all = Cinema.all
    r = {}
    # format is like this: r["2014-02-17"][cinema] -> array of screenings
    screenings_all.each do |s|
      r[s.date.to_s] ||= {}
      cinema = cinemas_all.find { |c| c.cinema_id == s.cinema_id }
      unless cinema.nil?
        r[s.date.to_s][cinema] ||= []
        r[s.date.to_s][cinema] << s
      end
    end

    r.each { |k, v| r[k] = v.sort_by { |k1, _v1| k1.name }.to_h } # sort cinemas by name
    r
  end

  def cinemas_count(city_id, active_all = false)
    if active_all == true
      screenings.active_all.in_city(city_id).pluck(:cinema_id).uniq.count
    else
      screenings.active.in_city(city_id).pluck(:cinema_id).uniq.count
    end
  end

  def screenings_count(city_id, active_all = false)
    if active_all == true
      screenings.active_all.in_city(city_id).count
    else
      screenings.active.in_city(city_id).count
    end
  end

  def to_s
    "\tMovie: [#{movie_id}][#{id}] #{title} (#{title_original})\n" \
    "\tActive: #{active}\n" \
    "\tKinopoisk, IMDb: #{kinopoisk_id}, #{imdb_id}\n" \
    "\t#{year}; #{country}; #{genres}; Age: #{age_restriction}\n" \
    "\tDirector: #{director}\n" \
    "\tCast: #{cast.to_s.delete("\r").split("\n").join(', ')}\n" \
    "\tDuration: #{duration}\n" \
    "\tPoster: #{poster}\n" \
    "\tCreated: #{created_at}\n" \
    "\tUpdated: #{updated_at}\n"
  end

  def trailer_original
    return nil if trailer.nil?

    trailer.split('*')[0]
  end

  def trailer_russian
    return nil if trailer.nil?

    trailer.split('*')[1]
  end

  def poster_url(timestamped = true)
    return nil unless poster_exists?

    "#{full_domain_name('msk')}#{poster_relative_url(timestamped)}"
  end

  def poster_relative_url(timestamped = true)
    return nil unless poster_exists?

    postfix = timestamped ? "?#{timestamp_poster}" : ''
    "/images/posters/#{id}.jpg#{postfix}"
  end

  def poster_filename
    "#{File.dirname(__FILE__)}/../public/images/posters/#{id}.jpg"
  end

  def poster_exists?
    File.exist?(poster_filename)
  end

  def timestamp_poster
    File.mtime(poster_filename).to_i.to_s rescue ''
  end

  def thumbnail_poster
    return unless poster_exists?

    img = Magick::Image.read(poster_filename)[0] rescue nil
    return if img.nil?

    max_width = 288
    ratio = img.rows * 1.0 / img.columns
    img = img.thumbnail(max_width, max_width * ratio)
    img.write poster_filename
  end

  def download_poster(url, force_rewrite = false)
    return if url.to_s.empty?
    return unless !poster_exists? || force_rewrite

    open(url) do |f|
      File.open(poster_filename, 'wb') do |file|
        file.puts f.read
      end
    end
    thumbnail_poster
    self.poster = url
    save
  rescue
    nil
  end

  def render_json(rating, screenings_count, next_screening)
    json_data = as_json(only: %w[age_restriction created_at duration id year])
    json_data['description'] = any_description.to_s.empty? ? nil : any_description
    json_data['title'] = {
      'original' => title_original,
      'russian' => title
    }
    json_data['trailer'] = {
      'original' => trailer_original,
      'russian' => trailer_russian
    }
    json_data['poster'] = poster_url
    json_data['cast'] = cast.to_s.empty? ? nil : cast.split(/,\ |\r\n|,\r\n/)
    json_data['directors'] = director.to_s.empty? ? nil : director.split(/,\ /)
    json_data['countries'] = country.to_s.empty? ? nil : country.split(/,\ /)
    json_data['genres'] = genres.to_s.empty? ? nil : genres.split(/,\ /)
    json_data['languages'] = languages.to_s.empty? ? nil : languages.split(/,\ /)
    json_data['rating'] = render_rating_json(rating)
    json_data['screenings'] = {
      'count' => screenings_count,
      'next' => next_screening
    }
    json_data.sort.to_h
  end

  def render_rating_json(rating)
    kp_rating = rating.kinopoisk_rating.round(1) rescue nil
    imdb_rating = rating.imdb_rating.round(1) rescue nil
    kp_votes = rating.kinopoisk_votes rescue nil
    imdb_votes = rating.imdb_votes rescue nil

    imdb_rating = nil if imdb_rating.to_i.zero?
    kp_rating = nil if kp_rating.to_i.zero?
    imdb_votes = nil if imdb_votes.to_i.zero?
    kp_votes = nil if kp_votes.to_i.zero?

    {
      'imdb':
        {
          'id': imdb_id,
          'rating': imdb_rating,
          'votes': imdb_votes
        },
      'kinopoisk':
        {
          'id': kinopoisk_id,
          'rating': kp_rating,
          'votes': kp_votes
        }
    }
  end
end
