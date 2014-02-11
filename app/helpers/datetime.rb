def time_strip(time)
	time.to_date.to_time
end

def time_next_day(time)
	time + 86400
end

def time_range_on_day(time)
	shift = 2 * 3600 # 2 hours
	(time_strip(time)  +shift ... time_strip(time_next_day(time)) + shift)
end