require 'date'

def parse_date(date)
	Date.parse(date).to_time rescue nil
end

def time_range_on_day(time)
	shift = SETTINGS[:new_day_starts_at]
	(time.strip + shift ... (time.next_day + 1.hour).strip + shift) #fuckup due to daylight savings
end

def date_for_screening(time)
	shift = SETTINGS[:new_day_starts_at]
	time.hour.hours + time.min.minutes >= shift ? time.strip : time.previous_day.strip
end

def show_time(time)
	time.strftime("%R")
end

def show_time_rambler(time)
	# '17-10-2014-1515'
	time.strftime("%d-%m-%Y-%H%M")
end

def weekdays
	['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье']
end

def show_date(date, with_day_of_week = true, capital = false)
	date = date.to_time
	months = ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря']
	return date.day.to_s + " " + months[date.month - 1] if with_day_of_week == false
	val = weekdays[date.wday - 1] + ", " + date.day.to_s + " " + months[date.month - 1]
	val = val.mb_chars.capitalize.to_s if capital
	val
end

def show_date_feed(date)
	"#{date.strftime('%d.%m')} (#{weekdays[date.wday - 1]})"
end

def show_date_time_feed(date)
	"#{date.strftime('%d.%m')} (#{weekdays[date.wday - 1]}) в #{date.strftime('%R')}"
end

def difference_in_days(time1, time2)
	diff = time2 - time1
	diff = -diff if diff < 0
	(diff / 86400).to_i
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