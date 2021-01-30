require 'json'

Subscity::App.controllers :cinemas do
  get :index, provides: %i[html json] do
    case content_type
    when :html
      cache(request.cache_key, expires: CACHE_TTL_LONG) do
        city = City.get_by_domain(request.subdomains.first)
        cinemas = city.sorted_cinemas
        title = 'Кинотеатры'
        render 'cinema/showall', layout: :layout, locals: { city: city, cinemas: cinemas, title: title }
      end
    when :json
      cache(request.cache_key, expires: CACHE_TTL_API) do
        city = City.get_by_domain(request.subdomains.first)
        cinemas = city.sorted_cinemas
        json_data = cinemas.map { |c, m| c.render_json(m) }

        sorting = cinema_sorting(params[:sort])
        json_data.sort_by!(&cinema_sorting_block(sorting[:field]))
        json_data.reverse! if sorting[:type] == '-'

        content_type :json, 'charset' => 'utf-8'
        return JSON.pretty_generate(json_data)
      end
    end
  end

  get :metrics, provides: [:json] do
    cache(request.cache_key, expires: CACHE_TTL_API) do
      city = City.get_by_domain(request.subdomains.first)
      cinemas = city.sorted_cinemas.keys rescue 0
      metrics = {}
      metrics['count'] = cinemas.length
      metrics['empty_geolocation'] = cinemas.select { |c| c.longitude.to_s.empty? || c.latitude.to_s.empty? }.length
      metrics['empty_address'] = cinemas.select { |c| c.address.to_s.empty? }.length
      metrics['empty_metro'] = cinemas.select { |c| c.metro.to_s.empty? }.length
      metrics['empty_phone'] = cinemas.select { |c| c.phone.to_s.empty? }.length
      metrics['empty_url'] = cinemas.select { |c| c.url.to_s.empty? }.length
      metrics['empty_anything'] = cinemas.select do |c|
        c.longitude.to_s.empty? || c.latitude.to_s.empty? ||
          c.url.to_s.empty? || c.phone.to_s.empty? || c.metro.to_s.empty? || c.address.to_s.empty?
      end.length
      content_type :json, 'charset' => 'utf-8'
      return JSON.pretty_generate(metrics)
    end
  end

  get :screenings, with: :id, id: /\d+.*/, provides: [:json] do
    cache(request.cache_key, expires: CACHE_TTL_API) do
      cinema = Cinema.find(params[:id]) rescue nil
      return '[]' unless cinema

      city = City.get_by_domain(request.subdomains.first)
      screenings = if SETTINGS[:movie_show_all_screenings]
                     Screening.active_all.where(cinema_id: cinema.cinema_id).order(:date_time)
                   else
                     Screening.active.where(cinema_id: cinema.cinema_id).order(:date_time)
                   end
      movies = city.movies.to_a
      json_data = screenings.map { |s| s.render_json([cinema], movies) }
      JSON.pretty_generate(json_data)
    end
  end

  get :index, with: :id, id: /\d+.*/ do
    cache(request.cache_key, expires: CACHE_TTL) do
      cinema = Cinema.find(params[:id])
      city = City.get_by_domain(request.subdomains.first)
      screenings = cinema.get_sorted_screenings(SETTINGS[:movie_show_all_screenings])
      movies = Movie.all
      screenings_flat = cinema.screenings.active
      price_min = screenings_flat.map(&:price_min).compact.min rescue nil
      price_max = screenings_flat.map(&:price_max).compact.max rescue nil
      title = cinema.name
      render 'cinema/show', layout: :layout, locals: {
        cinema: cinema, city: city, screenings: screenings, movies: movies, title: title,
        price_min: price_min, price_max: price_max
      }
    end
  rescue ActiveRecord::RecordNotFound
    render 'errors/404', layout: :layout
  end
end
