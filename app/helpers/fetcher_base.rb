require 'open-uri'
require 'net/http'
require 'uri'

module FetcherBase
  def	fetch_data(url, headers)
    res = open(url, headers)
    data = res.read
    # since we can have a gzipped response:
    data = Zlib::GzipReader.new(StringIO.new(data)).read if res.content_encoding == ['gzip']
    data
  rescue => e
    e.io.readlines.join
  end

  def fetch_data_post(url, params, headers = nil)
    domain = URI(url).host
    path = URI(url).path
    params = URI.encode_www_form(params) # convert params hash to query string
    http = Net::HTTP.new(domain, 80)
    http.read_timeout = headers[:read_timeout] if headers.key? :read_timeout
    headers.tap { |h| h.delete(:read_timeout) } rescue nil
    http.post(path, params, headers).body
  rescue
    nil
  end
end
