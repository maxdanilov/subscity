class Fixnum
	def seconds
		self
	end

	def minutes
		self * 60.seconds
	end

	def hours
		self * 60.minutes
	end

	def days
		self * 24.hours
	end

	alias_method :second, :seconds
	alias_method :minute, :minutes
	alias_method :hour, :hours
	alias_method :day, :days
end

def time_strip(time)
	time.to_date.to_time
end

def time_next_day(time)
	time + 1.day
end

def time_range_on_day(time)
	shift = 2.hours
	(time_strip(time) + shift ... time_strip(time_next_day(time)) + shift)
end

class Timer
	@flag
	def start(progress = true)
		@start = Time.now
		@flag = progress
		@thread = Thread.new do
			while @flag do
				sleep 1
				print '.'
			end
		end
		self
	end

	def stop(precision = 3)
		puts if @flag
		@flag = false
		@duration = (Time.now - @start).round(precision)
	end

	def get
		@duration
	end
end