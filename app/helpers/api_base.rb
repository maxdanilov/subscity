require 'json'

module ApiBase
  def base_url
    ENV['API_BASE_URL']
  end

  def	fetch_data(url)
    res = open(url)
    data = res.read
    data = Zlib::GzipReader.new(StringIO.new(data)).read if res.content_encoding == ['gzip']
    data
  rescue
    nil
  end

  def parse_json(data)
    JSON.parse(data) rescue nil
  end
end
