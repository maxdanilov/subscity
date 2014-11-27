DOMAIN_NAME = 'subscity.ru'

SETTINGS =  {
            	:screenings_show_span => 8,    		# in days
            	:screenings_fetch_span => 8,   		# in days
            	:movie_new_span => 7,				# in days
            	:sell_tickets => false,          	# sell tix within site or redirect to kassa
            	                                	# if sold within, 10% comission applied
            	:movie_show_all_screenings => true 	# not only active, but active_all
        	}   

COOKIES_TTL = 86400 * 30 # in seconds
CACHE_TTL = 1 * 3600 # in seconds
CACHE_TTL_LONG = 2 * 3600
LOG_FILE = File.dirname(__FILE__) + "/../tmp/performance.txt"