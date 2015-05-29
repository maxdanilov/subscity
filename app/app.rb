module Subscity
	require 'sinatra/synchrony'
  	class App < Padrino::Application
  		register Sinatra::Synchrony
	    use ActiveRecord::ConnectionAdapters::ConnectionManagement
	    register Padrino::Rendering
	    register Padrino::Mailer
	    register Padrino::Helpers
	    require 'json'
	    require 'geocoder'
	    require 'active_support/core_ext'
	    require 'translit'
	    require 'stringex'
	    require 'encrypted_cookie'
		require './app/settings'
		# sessions
		use Rack::Session::EncryptedCookie,
			:key => 'rack.session',
			:domain => DOMAIN_NAME,
			:path => '/',
			:expire_after => COOKIES_TTL,
	  		:secret => settings.session_secret

	    # caching 
	    register Padrino::Cache
	    enable :caching
	    Padrino.cache = Padrino::Cache.new(:File, :dir => FileCache.dir)

	    set :reload, false            # Reload application files (default in development)
	    set :protection, :except => [:json_csrf]

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
	            @screenings_all = Screening.active_all.in_city(@city.city_id).order(:date_time).select([:movie_id, :date_time]).to_a
	            @screenings_all.each do |s|
	                movie = @movies.find { |m| m.movie_id == s.movie_id}
	                next if movie.nil?
	                @screening_counts[movie] += 1
	                @next_screenings[movie] = s unless @next_screenings.has_key? movie
	            end
	            @ratings = Rating.where(:movie_id => @movies.map(&:movie_id));
	            @show_about = true
	            @title = "SubsCity :: Расписание сеансов на языке оригинала в кино (#{@city.name})"
	            render 'movie/showall', layout: :layout
	        end
	    end

	    get :latest do  
	    	auth_allow_for_role :admin                  
	        @screenings = Screening.active_all.order("created_at DESC, screening_id DESC").to_a      
	        @cities = City.all.to_a                         
	        @cinemas = Cinema.all.to_a                         
	        @movies = Movie.all.to_a            
	        @movies_active = Movie.where(:movie_id => Screening.active.pluck(:movie_id).uniq).order('created_at DESC')                         
	        @ratings = Rating.all
	        render 'latest', layout: :layout
	    end

	    get :clear do
	    	auth_allow_for_role :admin     
	    	FileCache.expire
	    	""            
	    end

	    get :screenings, :provides => [:rss] do
	        case content_type
	            when :rss
	                cache(request.cache_key, :expires => CACHE_TTL_SCREENINGS_FEED) do
	                    @city = City.get_by_domain(request.subdomains.first)
	                    @cinemas = @city.get_cinemas
	                    @movies = Movie.active
	                    @screenings = Screening.active_feed.in_city(@city.city_id).order("date_time ASC").limit(SETTINGS[:screenings_feed_max_count])
	                    builder :screenings, :locals => { :movies => @movies, :city => @city, :screenings => @screenings, :cinemas => @cinemas }
	            	end
	        end
	    end

	    get :sitemap, :provides => :xml do
	    	cache(request.cache_key, :expires => SITEMAP_TTL) do
		    	city = City.get_by_domain(request.subdomains.first)
	            movies_active = city.get_movies.sort_by { |a| a.created_at }.reverse
	            cinemas = city.get_sorted_cinemas
				today = date_for_screening(Time.now)		

		    	map = XmlSitemap::Map.new(request.subdomains.first + "." + domain_name, :time => Date.today) do |m|
	  				m.add 'movies', :priority => 1.0, :period => :daily
	  				m.add 'cinemas', :priority => 1.0, :period => :daily
	  				movies_active.each do |movie|
	  					m.add url_for(:movies, :index, :id => format_movie_url(movie)), :period => :daily, :priority => 0.8
	  				end
	  				cinemas.each do |cinema, movies|
	  					m.add url_for(:cinemas, :index, :id => format_cinema_url(cinema)), :period => :daily, :priority => 0.6
	  				end
					(0..7).each do |n|
						m.add url(:dates, :index, format_date_url(today + n.days)), :period => :daily, :priority => 0.6
					end
				end
				map.render
			end
		end
	    
	    #error 404 do
	    not_found do
	        render 'errors/404', layout: :layout
	    end
  	end
end