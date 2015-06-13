Subscity::App.controllers :dates do
    get :today, :provides => [:rss] do
        call env.merge("PATH_INFO" => url(:dates, :index, :date => format_date_url(date_for_screening(Time.now)), :format => content_type))
    end

    get :tomorrow, :provides => [:rss] do
        call env.merge("PATH_INFO" => url(:dates, :index, :date => format_date_url(date_for_screening(Time.now) + 1.day), :format => content_type))
    end

    get :overmorrow, :provides => [:rss] do
        call env.merge("PATH_INFO" => url(:dates, :index, :date => format_date_url(date_for_screening(Time.now) + 2.days), :format => content_type))
    end

    get :index, :provides => [:html, :rss], :with => :date, :date => /\d{4}-\d{2}-\d{2}/ do
        @date = parse_date(params[:date])
            unless @date.nil?
                case content_type
                    when :html
                        cache(request.cache_key, :expires => CACHE_TTL) do
                            @city = City.get_by_domain(request.subdomains.first)
                            @screenings = Screening.get_sorted_screenings(@date, @city.city_id, SETTINGS[:movie_show_all_screenings])
                            @movie = Movie.active
                            @cinemas = Cinema.all
                            @title = show_date(@date)
                            render 'date/show', layout: :layout
                        end
                    when :rss
                        cache(request.cache_key, :expires => CACHE_TTL_SCREENINGS_FEED) do
                            @city = City.get_by_domain(request.subdomains.first)
                            @screenings = Screening.get_sorted_screenings(@date, @city.city_id, SETTINGS[:movie_show_all_screenings])
                            @movie = Movie.active
                            @cinemas = Cinema.all
                            builder :dates, :locals => { :movies => @movie, :city => @city, :screenings => @screenings, :cinemas => @cinemas, :date => @date }
                        end
                end
            else
                render 'errors/404', layout: :layout
            end
    end
end