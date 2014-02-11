class Logger
	LOGNAME = 'log.txt'
	def self.put(data)
		file = File.open(LOGNAME, mode: 'a:UTF-8')
		file.write(Time.now.strftime("=== %d/%m/%Y %H:%M:%S ===\n"))
		file.write(data)
		file.write("\n\n")
		file.close
	end
end