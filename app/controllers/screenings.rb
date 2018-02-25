require 'json'

Subscity::App.controllers :screenings do
  get :index, provides: %i[rss] do
    case content_type
    when :rss
      cache(request.cache_key, expires: CACHE_TTL_SCREENINGS_FEED) do
        city = City.get_by_domain(request.subdomains.first)
        cinemas = city.cinemas
        movies = Movie.active.select { |m| !m.hidden? && !m.russian? }
        screenings = Screening.active_feed.in_city(city.city_id).order('date_time ASC')
                              .limit(SETTINGS[:screenings_feed_max_count])
        builder :screenings, locals: { movies: movies, city: city, screenings: screenings, cinemas: cinemas }
      end
    end
  end

  get :tickets, with: :id, id: /\d+.*/ do
    screening = Screening.find(params[:id]) rescue nil
    redirect(screening.tickets_url, 303) if screening
  end
end
