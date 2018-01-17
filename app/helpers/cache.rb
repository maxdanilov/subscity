class FileCache
  def self.expire
    FileUtils.rm_rf(Dir.glob(dir + '/*'))
  end

  def self.dir
    File.expand_path(__dir__) + '/../../tmp/subscity/app/cache'
  end
end
