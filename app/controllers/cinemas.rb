Subscity::App.controllers :cinemas do
    get :index do
        cache(request.cache_key, :expires => CACHE_TTL_LONG) do
            @city = City.get_by_domain(request.subdomains.first)
            @cinemas = @city.get_sorted_cinemas
            @title = "Кинотеатры"
            render 'cinema/showall', layout: :layout
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