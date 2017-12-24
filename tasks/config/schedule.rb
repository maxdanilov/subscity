# http://github.com/javan/whenever

job_type :job, 'cd :path && rake :task :output'

set :output, 'logs/cron.log'

# send DB backup to email
every :day, at: ['00:00'] do
	job 'backup', output: 'logs/cron.log'
end

# clean obsolete movies
every :day, at: ['03:30'] do
	job 'cleanup_movies', output: 'logs/cron_movies.log'
end

# movies
every :day, at: ['05:55', '10:05', '14:05', '19:00', '23:00'] do
	job 'update_movies', output: 'logs/cron_movies.log'
end

# kinopoisk ratings
every :day, at: ['06:10', '14:20', '22:15'] do
	job 'update_movie_ratings', output: 'logs/cron.log'
end

# cinemas
every :day, at: ['10:00', '14:00', '22:00'] do
	job 'update_cinemas', output: 'logs/cron_cinemas.log'
end

# screenings
every :day, at: ['07:05', '11:20', '14:50', '17:40', '20:40', '23:50'] do
	job 'update_screenings', output: 'logs/cron_screenings.log'
end

# clear cache
every :day, at: ['02:00'] do
	job 'clear_cache', output: 'logs/cron.log'
end
