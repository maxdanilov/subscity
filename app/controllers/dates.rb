require 'json'

Subscity::App.controllers :dates do
  get :today, provides: [:rss] do
    call env.merge('PATH_INFO' =>
      url(:dates, :index, date: format_date_url(date_for_screening(Time.now)), format: content_type))
  end

  get :tomorrow, provides: %i[rss] do
    call env.merge('PATH_INFO' =>
      url(:dates, :index, date: format_date_url(date_for_screening(Time.now) + 1.day), format: content_type))
  end

  get :overmorrow, provides: %i[rss] do
    call env.merge('PATH_INFO' =>
      url(:dates, :index, date: format_date_url(date_for_screening(Time.now) + 2.days), format: content_type))
  end

  get :screenings, provides: %i[json], with: :date, date: /\d{4}-\d{2}-\d{2}/ do
    cache(request.cache_key, expires: CACHE_TTL_API) do
      date = parse_date(params[:date])
      return '[]' unless date
      city = City.get_by_domain(request.subdomains.first)
      screenings = Screening.active_all.on_date(date).in_city(city.city_id).order(:date_time)
      movies = city.movies.to_a
      cinemas = city.sorted_cinemas.keys
      json_data = screenings.map { |s| s.render_json(cinemas, movies) }
      JSON.pretty_generate(json_data)
    end
  end

  get :index, provides: %i[html rss], with: :date, date: /\d{4}-\d{2}-\d{2}/ do
    date = parse_date(params[:date])
    if date.nil?
      render 'errors/404', layout: :layout
    else
      case content_type
      when :html
        cache(request.cache_key, expires: CACHE_TTL) do
          city = City.get_by_domain(request.subdomains.first)
          screenings = Screening.get_sorted_screenings(date, city.city_id, SETTINGS[:movie_show_all_screenings])
          movies = Movie.active
          cinemas = Cinema.all
          title = show_date(date)
          render 'date/show', layout: :layout, locals: {
            city: city, screenings: screenings, movies: movies, cinemas: cinemas, title: title, date: date
          }
        end
      when :rss
        cache(request.cache_key, expires: CACHE_TTL_SCREENINGS_FEED) do
          city = City.get_by_domain(request.subdomains.first)
          screenings = Screening.get_sorted_screenings(date, city.city_id, SETTINGS[:movie_show_all_screenings])
          movies = Movie.active
          cinemas = Cinema.all
          builder :dates, locals: {
            movies: movies, city: city, screenings: screenings, cinemas: cinemas, date: date
          }
        end
      end
    end
  end
end
