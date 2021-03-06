PROTOCOL = ENV['SC_PROTOCOL']
DOMAIN_NAME = ENV['SC_DOMAIN_NAME']
PORT = ENV['SC_PORT']

SETTINGS = {
  screenings_show_span: 8, # in days
  screenings_fetch_span: 5, # in days
  movie_new_span: 9, # in days
  movie_show_all_screenings: true, # not only active, but active_all
  movie_show_night_nonstops: false,
  new_day_starts_at: 2.hours + 30.minutes, # new day begins at 02:30, not 00:00
  screenings_feed_end: 72.hours,
  screenings_feed_start: 1.hour,
  screenings_feed_max_count: 100
}.freeze

# all in seconds:
COOKIES_TTL = 86_400 * 30
SITEMAP_TTL = 12 * 3600
CACHE_TTL = 1 * 3600
CACHE_TTL_LONG = 2 * 3600
CACHE_TTL_API = 900
CACHE_TTL_SCREENINGS_FEED = 1200

FETCH_MODE_CINEMA = { default: 0, all: 1 }.freeze
FETCH_MODE_MOVIE  = { default: 0, all: 1, subs: 2 }.freeze
# default - fetch subbed screenings for not fetch_all cinemas and all for fetch_all cinemas
# all - fetch all screenings
# subs - fetch subbed only, no matter if the cinema is fetch_all
FETCH_MODE = { cinema: FETCH_MODE_CINEMA, movie: FETCH_MODE_MOVIE }.freeze
