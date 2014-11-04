module Subscity
  class App < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register LessInitializer
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    require 'json'
    require 'geocoder'
    require 'active_support/core_ext'
    require 'translit'
    require 'stringex'
    require 'benchmark'
    enable :sessions

    require './app/settings'

    #
    # Caching support.
    #

    register Padrino::Cache
    enable :caching
    CACHE_TTL = 1 * 3600 # in seconds
    CACHE_TTL_LONG = 2 * 3600

    LOG_FILE = File.dirname(__FILE__) + "/../tmp/performance.txt"

    #CACHE_TTL = 1 # in seconds
    #Padrino.cache = Padrino::Cache.new(:File, :dir => Padrino.root('tmp', app_name.to_s, 'cache'))
    Padrino.cache = Padrino::Cache.new(:File, :dir => FileCache.dir)
    #
    # You can customize caching store engines:
    #
    # set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
    # set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
    # set :cache, Padrino::Cache::Store::Memory.new(50)
    # set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
    #

    ##
    # Application configuration options.
    #
    # set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
    # set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
    # set :show_exceptions, true    # Shows a stack trace in browser (default for development)
    # set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
    # set :public_folder, 'foo/bar' # Location for static assets (default root/public)
    set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

    set :protection, :except => [:json_csrf]

    ##
    # You can configure for a specified environment like:
    #
    #   configure :development do
    #     set :foo, :bar
    #     disable :asset_stamp # no asset timestamping for dev
    #   end
    #

    ##
    # You can manage errors like:
    #
    #   error 404 do
    #     render 'errors/404'
    #   end
    #
    #   error 505 do
    #     render 'errors/505'
    #   end
    #

    before do
        pre_redirect
        Slim::Engine.set_default_options :pretty => false, :sort_attrs => false, :enable_engines => nil # disabled engines to speed up things a bit
    end

    get :index do
        cache(request.cache_key, :expires => CACHE_TTL_LONG) do
            @city = City.get_by_domain(request.subdomains.first)
            @movies = @city.get_movies.to_a
            @movies = @movies.sort_by { |a| a.title.mb_chars.downcase.to_s }
            @new_movies = @movies.select {|a| (Time.now - a.created_at) <= SETTINGS[:movie_new_span].days}                       
            @cinema_count = @city.get_cinema_count
            @screening_counts = Hash.new(0)
            @next_screenings = {}
            @screenings_all = Screening.active.in_city(@city.city_id).order(:date_time).select([:movie_id, :date_time]).to_a
            @screenings_all.each do |s|
                movie = @movies.find { |m| m.movie_id == s.movie_id}
                next if movie.nil?
                @screening_counts[movie] += 1
                @next_screenings[movie] = s unless @next_screenings.has_key? movie
            end
            @ratings = Rating.where(:movie_id => @movies.map(&:movie_id));
            @show_about = true
            render 'movie/showall', layout: :layout
        end
    end

    get :latest do  
        if admin?                    
	        @screenings = Screening.active_all.order("created_at DESC, screening_id DESC").to_a      
	        @cities = City.all.to_a                         
	        @cinemas = Cinema.all.to_a                         
	        @movies = Movie.all.to_a            
	        @movies_active = Movie.where(:movie_id => Screening.active.pluck(:movie_id).uniq).order('created_at DESC')                         
	        @ratings = Rating.all
	        render 'latest', layout: :layout
    	else
    		render 'errors/404', layout: :layout
    	end
    end

    get :cinemas do
        cache(request.cache_key, :expires => CACHE_TTL_LONG) do
            @city = City.get_by_domain(request.subdomains.first)
            @cinemas = @city.get_sorted_cinemas
            @title = "Кинотеатры"
            render 'cinema/showall', layout: :layout
        end
    end

    get :dates, :with => :date, :date => /\d{4}-\d{2}-\d{2}/ do
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

    get :movies, :provides => [:html, :rss] do
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
                    @screenings_all = Screening.active.in_city(@city.city_id).order(:date_time).select([:movie_id, :date_time]).to_a
                    @screenings_all.each do |s|
                        movie = @movies.find { |m| m.movie_id == s.movie_id}
                        next if movie.nil?
                        @screening_counts[movie] += 1
                        @next_screenings[movie] = s unless @next_screenings.has_key? movie
                    end
                    @ratings = Rating.where(:movie_id => @movies.map(&:movie_id));
                    @title = "Фильмы"
                    render 'movie/showall', layout: :layout
                end
            when :rss
                cache(request.cache_key, :expires => CACHE_TTL) do
                    @city = City.get_by_domain(request.subdomains.first)
                    @movies_active = @city.get_movies.sort_by { |a| a.created_at }.reverse
                    builder :feed, :locals => { :movies => @movies_active, :city => @city}
                end
        end
    end

    get :movies, :with => :id, :id => /\d+.*/ do
        begin
            cache(request.cache_key, :expires => CACHE_TTL) do
                @movie = Movie.find(params[:id])
                @ratings = Rating.where(:movie_id => @movie.movie_id).first rescue nil
                @city = City.get_by_domain(request.subdomains.first)
                @screenings = @movie.get_sorted_screenings(@city.city_id) # @movie.screenings
                @cinemas = Cinema.all

                @screening_count = @movie.screenings_count(@city.city_id)
                @cinemas_count = @movie.cinemas_count(@city.city_id)

                screenings_flat = @movie.screenings.active
                @price_min = screenings_flat.map{ |s| s.price_min}.compact.min rescue nil
                @price_max = screenings_flat.map{ |s| s.price_max}.compact.max rescue nil
                @title = @movie.title
                if not @movie.title_original.to_s.empty?
                    @title += " (#{@movie.title_original})"
                end
                render 'movie/show', layout: :layout
            end
        rescue ActiveRecord::RecordNotFound => e
            render 'errors/404', layout: :layout
        end
    end

    get [:movies, :update] do
        if admin?
            @movies = Movie.all
            render 'movie/update', layout: :layout
        else
            render 'errors/404', layout: :layout
        end
    end

    post [:movies, :update] do #, :with => [:id, :kinopoisk_id, :imdb_id, :trailers], :id => /\d+/, :kinopoisk_id => /\d+/, :imdb_id => /t{0,2}\d+/ do
        if admin?
            #cmd = "cd #{File.dirname(__FILE__)}/../tasks && rake update_movie_info[#{params[:id]},#{params[:kinopoisk_id]},#{params[:imdb_id]}] >> /home/nas/rake.log 2>&1"
            cmd = "cd #{File.dirname(__FILE__)}/../tasks && rake update_movie_info[#{params[:id]},#{params[:kinopoisk_id]},#{params[:imdb_id]},#{params[:trailers]}]"
            result = `#{cmd}`
            "#{result}"
        else
            render 'errors/404', layout: :layout
        end
    end

    get :cinemas, :with => :id, :id => /\d+.*/ do
        begin
            cache(request.cache_key, :expires => CACHE_TTL) do
                @cinema = Cinema.find(params[:id])
                @city = City.get_by_domain(request.subdomains.first)
                @screenings = @cinema.get_sorted_screenings
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

    #error 404 do
    not_found do
        render 'errors/404', layout: :layout
    end
end
end