Subscity::App.controllers :dates do
    get :index, :with => :date, :date => /\d{4}-\d{2}-\d{2}/ do
        @date = parse_date(params[:date])
            unless @date.nil?
                cache(request.cache_key, :expires => CACHE_TTL) do
                    @city = City.get_by_domain(request.subdomains.first)
                    @screenings = Screening.get_sorted_screenings(@date, @city.city_id)
                    @movie = Movie.active
                    @cinemas = Cinema.all
                    @title = show_date(@date)
                    render 'date/show', layout: :layout
                end
            else
                render 'errors/404', layout: :layout
            end
    end
end