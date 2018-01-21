require 'json'

Subscity::App.controllers :movies do
  get :edit, map: '/movies/:id/edit' do
    auth_allow_for_role :admin
    id = params[:id].to_i rescue 0
    if id.positive?
      begin
        @movie = Movie.find(id)
        @title = '[e] ' << @movie.title
        render 'movie/edit', layout: :layout
      rescue ActiveRecord::RecordNotFound
        render 'errors/404', layout: :layout
      end
    else
      render 'errors/404', layout: :layout
    end
  end

  post :edit, map: '/movies/:id/edit' do
    id = params[:id].to_i rescue 0
    if id.positive? && admin?
      begin
        m = Movie.find(id)
        params.each do |k, v|
          next if k == 'id'
          next unless m.has_attribute? k
          v.gsub!(/\D/, '') if Movie.columns_hash[k].type == :integer
          v = nil if v.empty? && (%i[text string].include? Movie.columns_hash[k].type)
          m.update_attribute(k, v)
        end

        Kinopoisk.update_ratings(m)
        m.download_poster(params[:new_poster], true)
        File.delete m.poster_filename rescue nil if params[:new_poster].downcase.strip == 'delete'
        FileCache.expire
        redirect(url(request.path))
      rescue ActiveRecord::RecordNotFound
        render 'errors/404', layout: :layout
      end
    else
      render 'errors/404', layout: :layout
    end
  end

  get :index, provides: %i[html rss json] do
    case content_type
    when :html
      cache(request.cache_key, expires: CACHE_TTL_LONG) do
        @city = City.get_by_domain(request.subdomains.first)
        @movies = @city.get_movies.to_a
        @movies = @movies.sort_by { |a| a.title.mb_chars.downcase.to_s }
        @new_movies = @movies.select { |a| (Time.now - a.created_at) <= SETTINGS[:movie_new_span].days }
        @cinema_count = @city.get_cinema_count
        @screening_counts = Hash.new(0)
        @next_screenings = {}
        @screenings_all = Screening.active_all.in_city(@city.city_id).order(:date_time)
                                   .select(%i[movie_id date_time]).to_a
        @screenings_all.each do |s|
          movie = @movies.find { |m| m.movie_id == s.movie_id }
          next if movie.nil?
          @screening_counts[movie] += 1
          @next_screenings[movie] = s unless @next_screenings.key? movie
        end
        @ratings = Rating.where(movie_id: @movies.map(&:movie_id))
        @title = "Фильмы на языке оригинала в кино (#{@city.name})"
        render 'movie/showall', layout: :layout
      end
    when :rss
      cache(request.cache_key, expires: CACHE_TTL) do
        @city = City.get_by_domain(request.subdomains.first)
        @movies_active = @city.get_movies.sort_by(&:created_at).reverse
        builder :feed, locals: { movies: @movies_active, city: @city }
      end
    when :json
      cache(request.cache_key, expires: CACHE_TTL_API) do
        city = City.get_by_domain(request.subdomains.first)
        movies = city.get_movies.sort_by(&:created_at).reverse

        screening_counts = Hash.new(0)
        next_screenings = {}
        screenings_all = Screening.active_all.in_city(city.city_id).order(:date_time)
                                  .select(%i[movie_id date_time]).to_a
        screenings_all.each do |s|
          movie = movies.find { |m| m.movie_id == s.movie_id } rescue nil
          next if movie.nil?
          screening_counts[movie] += 1
          next_screenings[movie] = s unless next_screenings.key? movie
        end
        ratings = Rating.where(movie_id: movies.map(&:movie_id))

        json_data = movies.map do |m|
          rating = ratings.find { |r| r.movie_id == m.movie_id } rescue nil
          r = m.render_json(rating, screening_counts[m], next_screenings[m].date_time)
          r.sort.to_h
        end

        JSON.pretty_generate(json_data)
      end
    end
  end

  get :screenings, with: :id, id: /\d+.*/, provides: %i[json] do
    cache(request.cache_key, expires: CACHE_TTL_API) do
      movie = Movie.find(params[:id]) rescue nil
      return '[]' unless movie

      city = City.get_by_domain(request.subdomains.first)
      cinemas = city.get_sorted_cinemas.keys

      screenings = if SETTINGS[:movie_show_all_screenings]
                     movie.get_screenings_all(city.city_id)
                   else
                     movie.get_screenings(city.city_id)
                   end

      json_data = screenings.as_json(except: %w[created_at updated_at id movie_id]).map do |v|
        v['cinema_id'] = cinemas.find { |c| c.cinema_id == v['cinema_id'] }.id rescue nil
        v
      end
      JSON.pretty_generate(json_data)
    end
  end

  get :index, with: :id, id: /\d+.*/, provides: %i[html txt] do
    begin
      case content_type
      when :html
        cache(request.cache_key, expires: CACHE_TTL) do
          show_all_screenings = SETTINGS[:movie_show_all_screenings]
          @movie = Movie.find(params[:id])
          @ratings = Rating.where(movie_id: @movie.movie_id).first rescue nil
          @city = City.get_by_domain(request.subdomains.first)
          @screenings = @movie.get_sorted_screenings(@city.city_id, show_all_screenings)
          @cinemas = Cinema.all

          @screening_count = @movie.screenings_count(@city.city_id, show_all_screenings)
          @cinemas_count = @movie.cinemas_count(@city.city_id, show_all_screenings)

          screenings_flat = if show_all_screenings
                              @movie.get_screenings @city.city_id
                            else
                              @movie.get_screenings_all @city.city_id
                            end
          @price_min = screenings_flat.map(&:price_min).compact.min rescue nil
          @price_max = screenings_flat.map(&:price_max).compact.max rescue nil
          @title = @movie.title
          @title += " (#{@movie.title_original})" unless @movie.title_original.to_s.empty?
          @title += ' на языке оригинала в кино'
          render 'movie/show', layout: :layout
        end
      when :txt
        auth_allow_for_role :admin
        @city = City.get_by_domain(request.subdomains.first)
        @movie = Movie.find(params[:id]) rescue nil
        @ratings = Rating.where(movie_id: @movie.movie_id).first rescue nil
        render 'movie/show.text'
      else
        render 'errors/404', layout: :layout
      end
    rescue ActiveRecord::RecordNotFound
      render 'errors/404', layout: :layout
    end
  end
end
