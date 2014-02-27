require 'date'

def parse_date(date)
	Date.parse(date).to_time rescue nil
end

def time_range_on_day(time)
	shift = 2.hours
	(time.strip + shift ... time.next_day.strip + shift)
end

def date_for_screening(time)
	shift_hours = 2 
	time.hour >= shift_hours ? time.strip : time.previous_day.strip
end

def show_time(time)
	time.strftime("%R") 
end

def show_date(date)
	date = date.to_time
	#date.to_time.strftime("%^a, %d %B %Y")
	#weekdays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС']
	weekdays = ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье']
	months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря']
	weekdays[date.wday - 1] + ", " + date.day.to_s + " " + months[date.month - 1]
end

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

class Time
	def strip
		to_date.to_time
	end

	def next_day
		self + 1.day
	end

	def previous_day
		self - 1.day
	end
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