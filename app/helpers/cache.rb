class FileCache
	def self.expire
		FileUtils.rm_rf(Dir.glob(self.dir + '/*'))
	end

	def self.dir
		#Padrino.root('tmp', app_name.to_s, 'cache')
		File.expand_path(File.dirname(__FILE__)) + "/../../tmp/subscity/app/cache"
	end
end