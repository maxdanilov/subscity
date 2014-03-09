# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

job_type :my_rake, 'cd :path && rake :task :output'

set :output, 'logs/cron.log'

#movies
every :day, :at => ['10:05', '14:00'] do
	my_rake "update_movies", :output => 'logs/cron_movies.log'
end

#kinopoisk ratings
every :day, :at => ['10:10', '14:05'] do
	#my_rake "update_kinopoisk_buttons", :output => 'logs/cron.log'
	my_rake "update_movie_ratings", :output => 'logs/cron.log'
end

#cinemas
every :day, :at => ['10:15', '14:15'] do
	my_rake "update_cinemas", :output => 'logs/cron_cinemas.log'
end

#screenings
every :day, :at => ['11:18', '14:50', '17:41', '20:41'] do
	my_rake "update_screenings", :output => 'logs/cron_screenings.log'
end

every :day, :at => ['11:58', '14:58', '18:24', '20:59'] do
	my_rake "cleanup_screenings", :output => 'logs/cron_screenings.log'
end

# prices
every :day, :at => ['12:31', '15:12', '19:20', '21:20'] do
	my_rake "update_screenings_prices", :output => 'logs/cron_prices.log'
end
