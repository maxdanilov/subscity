require 'json'

Subscity::App.controllers :cinemas do
    get :index, :provides => [:html, :json] do
        case content_type
            when :html
                cache(request.cache_key, :expires => CACHE_TTL_LONG) do
                    @city = City.get_by_domain(request.subdomains.first)
                    @cinemas = @city.get_sorted_cinemas
                    @title = "Кинотеатры"
                    render 'cinema/showall', layout: :layout
                end
            when :json
                cache(request.cache_key, :expires => CACHE_TTL_API) do
                    city = City.get_by_domain(request.subdomains.first)
                    cinemas = city.get_sorted_cinemas
                    json_data = cinemas.map { |c, m| c.render_json(m) }
                    content_type :json, 'charset' => 'utf-8'
                    return JSON.pretty_generate(json_data)
                end
        end
    end

    get :metrics, :provides => [:json] do
        cache(request.cache_key, :expires => CACHE_TTL_API) do
            city = City.get_by_domain(request.subdomains.first)
            cinemas = city.get_sorted_cinemas.keys rescue 0
            metrics = {}
            metrics['count'] = cinemas.length
            metrics['no_geolocation'] = cinemas.select { |c| c.longitude.to_s.empty? or c.latitude.to_s.empty?}.length
            metrics['no_address'] = cinemas.select { |c| c.address.to_s.empty? }.length
            metrics['no_metro'] = cinemas.select { |c| c.metro.to_s.empty? }.length
            metrics['no_phone'] = cinemas.select { |c| c.phone.to_s.empty? }.length
            metrics['no_url'] = cinemas.select { |c| c.url.to_s.empty? }.length
            content_type :json, 'charset' => 'utf-8'
            return JSON.pretty_generate(metrics)
        end
    end

    get :screenings, :with => :id, :id => /\d+.*/, :provides => [:json] do
        cache(request.cache_key, :expires => CACHE_TTL_API) do
            cinema = Cinema.find(params[:id]) rescue nil
            return "[]" unless cinema

            city = City.get_by_domain(request.subdomains.first)
            if SETTINGS[:movie_show_all_screenings]
                screenings = Screening.active_all.where(:cinema_id => cinema.cinema_id).order(:date_time)
            else
                screenings = Screening.active.where(:cinema_id => cinema.cinema_id).order(:date_time)
            end
            movies = city.get_movies.to_a
            json_data = screenings.as_json(:except => ['cinema_id', 'created_at', 'updated_at', 'id']).
                        map { |v| v['movie_id'] = movies.find{|m| m.movie_id == v['movie_id'] }.id rescue nil ; v }
            JSON.pretty_generate(json_data)
        end
    end

    get :index, :with => :id, :id => /\d+.*/ do
        begin
            cache(request.cache_key, :expires => CACHE_TTL) do
                @cinema = Cinema.find(params[:id])
                @city = City.get_by_domain(request.subdomains.first)
                @screenings = @cinema.get_sorted_screenings(SETTINGS[:movie_show_all_screenings])
                @movies = Movie.all
                screenings_flat = @cinema.screenings.active
                @price_min = screenings_flat.map {|s| s.price_min}.compact.min rescue nil
                @price_max = screenings_flat.map {|s| s.price_max}.compact.max rescue nil
                @title = @cinema.name
                render 'cinema/show', layout: :layout
            end
        rescue ActiveRecord::RecordNotFound => e
            render 'errors/404', layout: :layout
        end
    end
end