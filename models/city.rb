class City < ActiveRecord::Base
  has_many :cinemas, primary_key: 'city_id'

  validates :name, presence: true, uniqueness: true
  validates :city_id, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  def cinema_count
    Screening.active.in_city(city_id).order(:date_time).pluck(:cinema_id).uniq.count
  end

  # need to optimise, takes like 0.5 secs to run!
  def sorted_cinemas
    @screenings_all = Screening.active.in_city(city_id).order(:date_time).to_a
    @movies_all = movies.to_a
    @cinemas_all = Cinema.where(city_id: city_id).to_a

    @r = {}
    # format is like this: r[cinema][movie] = screenings count
    @screenings_all.each do |s|
      cinema = @cinemas_all.find { |c| c.cinema_id == s.cinema_id }
      movie = @movies_all.find { |c| c.movie_id == s.movie_id }
      next if cinema.nil? || movie.nil? || cinema.city_id != city_id

      @r[cinema] ||= {}
      @r[cinema][movie] ||= 0
      @r[cinema][movie] += 1
    end

    @r = @r.sort_by { |k, _v| k.name }.to_h # sort cinemas by name
    @r.each { |k, v| @r[k] = v.sort_by { |k1, _v1| k1.title }.to_h } # sort movies by title
    @r
  end

  def movies
    # Movie.joins(:screenings).merge(Screening.active.in_city(city_id)).uniq.select { |m| not m.russian? }
    # this is faster (but 2 requests):
    Movie.where(movie_id: Screening.active.in_city(city_id).pluck(:movie_id).uniq)
         .select { |m| !m.hidden? && !m.russian? }
  end

  def cinemas
    Cinema.where(city_id: city_id)
  end

  def self.get_by_domain(domain)
    City.where(domain: domain).first rescue nil
  end
end
