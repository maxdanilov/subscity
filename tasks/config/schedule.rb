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

# send DB backup to email
every :day, :at => ['00:00'] do
	my_rake "backup", :output => 'logs/cron.log'
end

#clean obsolete movies
every :day, :at => ['03:30'] do
	my_rake "cleanup_movies", :output => 'logs/cron_movies.log'
end

#movies
every :day, :at => ['05:55', '10:05', '14:05', '19:00', '23:00'] do
	my_rake "update_movies", :output => 'logs/cron_movies.log'
end

#kinopoisk ratings
every :day, :at => ['06:10', '14:20', '22:15'] do
	my_rake "update_movie_ratings", :output => 'logs/cron.log'
end

#cinemas
every :day, :at => ['10:00', '14:00', '22:00'] do
	my_rake "update_cinemas", :output => 'logs/cron_cinemas.log'
end

#screenings
every :day, :at => ['07:05', '11:20', '14:50', '17:40', '20:40', '23:50'] do
	my_rake "update_screenings", :output => 'logs/cron_screenings.log'
end

# clear cache
every :day, :at => ['02:00'] do
	my_rake "clear_cache", :output => 'logs/cron.log'
end
