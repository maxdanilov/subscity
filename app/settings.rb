DOMAIN_NAME = 'subscity.ru'

SETTINGS =  {
            	:screenings_show_span => 8,    				# in days
            	:screenings_fetch_span => 8,   				# in days
            	:movie_new_span => 7,						# in days
            	:sell_tickets => false,          			# sell tix within site or redirect to kassa
            	                                			# if sold within, 10% comission applied
            	:movie_show_all_screenings => true,			# not only active, but active_all
            	:new_day_starts_at => 2.hours + 30.minutes 	# new day begins at 02:30, not 00:00
        	}   

COOKIES_TTL = 86400 * 30 # in seconds
CACHE_TTL = 1 * 3600 # in seconds
CACHE_TTL_LONG = 2 * 3600
LOG_FILE = File.dirname(__FILE__) + "/../tmp/performance.txt"

FETCH_MODE_CINEMA = { :default => 0, :all => 1 }
FETCH_MODE_MOVIE  = { :default => 0, :all => 1, :subs => 2 }	# default - fetch subbed screenings for not fetch_all cinemas and all for fetch_all cinemas
																# all - fetch all screenings
																# subs - fetch subbed only, no matter if the cinema is fetch_all
FETCH_MODE = { :cinema => FETCH_MODE_CINEMA, :movie => FETCH_MODE_MOVIE }																
