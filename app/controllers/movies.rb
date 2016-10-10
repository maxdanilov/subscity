require 'json'

Subscity::App.controllers :movies do
    # bulk movie updating

    get :update, :map => "/movies/update" do
        auth_allow_for_role :admin
        @movies = Movie.all
        @title = "[e] Фильмы"
        render 'movie/update', layout: :layout
    end

    post :update, :map => "/movies/update" do
        if admin?
            #cmd = "cd #{File.dirname(__FILE__)}/../../tasks && rake update_movie_info[#{params[:id]},#{params[:kinopoisk_id]},#{params[:imdb_id]}] >> /home/nas/rake.log 2>&1"
            cmd = "cd #{File.dirname(__FILE__)}/../../tasks && rake update_movie_info[#{params[:id]},#{params[:kinopoisk_id]},#{params[:imdb_id]},#{params[:trailers]}]"
            result = `#{cmd}`
            "#{result}"
        else
            render 'errors/404', layout: :layout
        end
    end

    # particular movie editing

    get :edit, :map => "/movies/:id/edit" do
        auth_allow_for_role :admin
        id = params[:id].to_i rescue 0
        if id > 0
            begin
                @movie = Movie.find(id)
                @title = "[e] " << @movie.title
                render 'movie/edit', layout: :layout
            rescue ActiveRecord::RecordNotFound => e
                render 'errors/404', layout: :layout
            end
        else
            render 'errors/404', layout: :layout
        end
    end

    post :edit, :map => "/movies/:id/edit" do
        id = params[:id].to_i rescue 0
        if id > 0 and admin?
            begin
                m = Movie.find(id)
                params.each do |k,v|
                    next if k == "id"
                    if m.has_attribute? k
                        v.gsub!(/\D/, '') if Movie.columns_hash[k].type == :integer
                        v = nil if v.empty? and [:text, :string].include? Movie.columns_hash[k].type
                        m.update_attribute(k, v)
                    end
                end

                # ratings update
                Kinopoisk.update_ratings(m)
                # poster update
                m.download_poster(params[:new_poster], true) unless params[:new_poster].empty?
                # poster delete
                if params[:new_poster].downcase.strip == "delete"
                    File.delete m.poster_filename rescue nil
                end

                FileCache.expire

                #redirect(url_for(:movie_edit, :id => params[:id]))
                redirect(url(request.path))
            rescue ActiveRecord::RecordNotFound => e
                render 'errors/404', layout: :layout
            end
        else
            render 'errors/404', layout: :layout
        end
    end

    # movies showing

    get :index, :provides => [:html, :rss, :json] do
        case content_type
            when :html
                cache(request.cache_key, :expires => CACHE_TTL_LONG) do
                    @city = City.get_by_domain(request.subdomains.first)
                    @movies = @city.get_movies.to_a
                    @movies = @movies.sort_by { |a| a.title.mb_chars.downcase.to_s }
                    @new_movies = @movies.select {|a| (Time.now - a.created_at) <= SETTINGS[:movie_new_span].days}
                    @cinema_count = @city.get_cinema_count
                    @screening_counts = Hash.new(0)
                    @next_screenings = {}
                    @screenings_all = Screening.active_all.in_city(@city.city_id).order(:date_time).select([:movie_id, :date_time]).to_a
                    @screenings_all.each do |s|
                        movie = @movies.find { |m| m.movie_id == s.movie_id}
                        next if movie.nil?
                        @screening_counts[movie] += 1
                        @next_screenings[movie] = s unless @next_screenings.has_key? movie
                    end
                    @ratings = Rating.where(:movie_id => @movies.map(&:movie_id));
                    @title = "Фильмы на языке оригинала в кино (#{@city.name})"
                    render 'movie/showall', layout: :layout
                end
            when :rss
                cache(request.cache_key, :expires => CACHE_TTL) do
                    @city = City.get_by_domain(request.subdomains.first)
                    @movies_active = @city.get_movies.sort_by { |a| a.created_at }.reverse
                    builder :feed, :locals => { :movies => @movies_active, :city => @city}
                end
            when :json
                cache(request.cache_key, :expires => CACHE_TTL_API) do
                    city = City.get_by_domain(request.subdomains.first)
                    movies_active = city.get_movies.sort_by { |a| a.created_at }.reverse
                    json_data = movies_active.map{ |m|
                        j = m.as_json(:except => ['active', 'fetch_mode', 'hide', 'movie_id',
                                                  'updated_at', 'poster', 'trailer']);
                        j['trailer_original'] = m.trailer_original;
                        j['trailer_russian'] = m.trailer_russian;
                        j['poster'] = m.poster_url;
                        j.sort.to_h }
                    JSON.pretty_generate(json_data)
                end
        end
    end

    get :screenings, :with => :id, :id => /\d+.*/, :provides => [:json] do
        cache(request.cache_key, :expires => CACHE_TTL_API) do
            movie = Movie.find(params[:id]) rescue nil
            return "[]" unless movie

            city = City.get_by_domain(request.subdomains.first)
            cinemas = city.get_sorted_cinemas.keys

            if SETTINGS[:movie_show_all_screenings]
                screenings = movie.get_screenings_all(city.city_id)
            else
                screenings = movie.get_screenings(city.city_id)
            end
            
            json_data = screenings.as_json(:except => ['created_at', 'updated_at', 'id', 'movie_id']).
                        map { |v| v['cinema_id'] = cinemas.find { |c| c.cinema_id == v['cinema_id'] }.id rescue nil ;
                                  v }
            JSON.pretty_generate(json_data)
        end
    end

    get :index, :with => :id, :id => /\d+.*/, :provides => [:html, :txt] do
        begin
            case content_type
                when :html
                    cache(request.cache_key, :expires => CACHE_TTL) do
                        show_all_screenings = SETTINGS[:movie_show_all_screenings]
                        @movie = Movie.find(params[:id])
                        @ratings = Rating.where(:movie_id => @movie.movie_id).first rescue nil
                        @city = City.get_by_domain(request.subdomains.first)
                        @screenings = @movie.get_sorted_screenings(@city.city_id, show_all_screenings) # @movie.screenings
                        @cinemas = Cinema.all

                        @screening_count = @movie.screenings_count(@city.city_id, show_all_screenings)
                        @cinemas_count = @movie.cinemas_count(@city.city_id, show_all_screenings)

                        if show_all_screenings
                            screenings_flat = @movie.get_screenings @city.city_id #@movie.screenings.active
                        else
                            screenings_flat = @movie.get_screenings_all @city.city_id
                        end
                        @price_min = screenings_flat.map{ |s| s.price_min}.compact.min rescue nil
                        @price_max = screenings_flat.map{ |s| s.price_max}.compact.max rescue nil
                        @title = @movie.title
                        if not @movie.title_original.to_s.empty?
                            @title += " (#{@movie.title_original})"
                        end
                        @title += " на языке оригинала в кино"
                        render 'movie/show', layout: :layout
                    end
                when :txt
                    auth_allow_for_role :admin
                    @city = City.get_by_domain(request.subdomains.first)
                    @movie = Movie.find(params[:id]) rescue nil
                    @ratings = Rating.where(:movie_id => @movie.movie_id).first rescue nil
                    render 'movie/show.text'
                else
                    render 'errors/404', layout: :layout
            end
        rescue ActiveRecord::RecordNotFound => e
            render 'errors/404', layout: :layout
        end
    end
end
