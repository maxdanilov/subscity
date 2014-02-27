module Subscity
  class App < Padrino::Application
    use ActiveRecord::ConnectionAdapters::ConnectionManagement
    register LessInitializer
    register Padrino::Rendering
    register Padrino::Mailer
    register Padrino::Helpers
    require 'json'
    require 'geocoder'

    enable :sessions

    ##
    # Caching support.
    #
    # register Padrino::Cache
    # enable :caching
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
    # set :reload, false            # Reload application files (default in development)
    # set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
    # set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
    # disable :sessions             # Disabled sessions by default (enable if needed)
    # disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
    # layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
    #

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
    #before '/movies' do
    before do
        pre_redirect
    end

	get '/' do
        "#{request.subdomains.join("<br/>")} #{request.ip} D: #{request.get_subdomain}"
	end

    get '/cinemas' do
        Slim::Engine.set_default_options :pretty => true, :sort_attrs => false
        @city = City.get_by_domain(request.subdomains.first)
        @cinemas = @city.get_sorted_cinemas
        @nav_links_styles = {cinemas: "active"}
        render 'cinema/showall', layout: :layout
    end

    get '/dates/:date' do
        Slim::Engine.set_default_options :pretty => true, :sort_attrs => false
        @date = parse_date(params[:date])
        unless @date.nil?
            @city = City.get_by_domain(request.subdomains.first)
            @screenings = Screening.get_sorted_screenings(@date, @city.city_id)
            @movie = Movie.active
            @cinemas = Cinema.all
            @nav_links_styles = {dates: "active"}
            render 'date/show', layout: :layout
        else
            render 'errors/404', layout: :layout
        end
    end

    get '/movies' do
        Slim::Engine.set_default_options :pretty => true, :sort_attrs => false
        @city = City.get_by_domain(request.subdomains.first)
        @movies = @city.get_movies
        @movies = @movies.sort_by { |a| a.title }
        @new_movies = @movies.select {|a| (Time.now - a.created_at) <= 8.days}
        @screening_counts = Hash[@movies.map { |movie| {movie => movie.screenings_count(@city.city_id)}.flatten}]
        @cinemas_counts = Hash[@movies.map { |movie| {movie => movie.cinemas_count(@city.city_id)}.flatten}]
        @nav_links_styles = {movies: "active"}
        render 'movie/showall', layout: :layout
        #"#{self.class} #{request.subdomain_valid?.to_s}<br>#{request.subdomains}<br>#{request.host} #{request.path}"
    end

    get '/movies/:id' do
        begin
            Slim::Engine.set_default_options :pretty => true, :sort_attrs => false
            @movie = Movie.find(params[:id])
            @city = City.get_by_domain(request.subdomains.first)
            @screenings = @movie.get_sorted_screenings(@city.city_id) # @movie.screenings
            @cinemas = Cinema.all

            screenings_flat = @movie.screenings.active
            @price_min = screenings_flat.map{ |s| s.price_min}.compact.min rescue nil
            @price_max = screenings_flat.map{ |s| s.price_max}.compact.max rescue nil
            @nav_links_styles = {movies: "active"}
            render 'movie/show', layout: :layout
        rescue ActiveRecord::RecordNotFound => e
            render 'errors/404', layout: :layout
        end
    end

    get '/cinemas/:id' do
        begin
            Slim::Engine.set_default_options :pretty => true, :sort_attrs => false
            @cinema = Cinema.find(params[:id])
            #@city = City.where(:city_id => @cinema.city_id).first
            @city = City.get_by_domain(request.subdomains.first)
            @screenings = @cinema.get_sorted_screenings
            @movies = Movie.all
            screenings_flat = @cinema.screenings.active
            @price_min = screenings_flat.map {|s| s.price_min}.compact.min rescue nil
            @price_max = screenings_flat.map {|s| s.price_max}.compact.max rescue nil
            #@nav_links_styles = {movies: "", cinemas: "active", dates: "", about: ""}
            @nav_links_styles = {cinemas: "active"}
            render 'cinema/show', layout: :layout
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