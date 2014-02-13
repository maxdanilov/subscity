require 'open-uri'
require 'net/http'
require 'uri'

module FetcherBase
	#def	fetch_data(url, headers = STANDARD_HEADERS)	
	def	fetch_data(url, headers)	
		begin
			res = open(url, headers)
			data = res.read 
			# since we can have a gzipped response:
			data = Zlib::GzipReader.new(StringIO.new(data)).read if res.content_encoding == ['gzip']
			data
		rescue Exception => e	
			nil
		end
	end

	def fetch_data_post(url, params, headers = nil)
		begin
			domain = URI(url).host
			path = URI(url).path
			# convert params hash to query string
			params = URI.encode_www_form(params)
			Net::HTTP.new(domain, 80).post(path, params, headers).body
		rescue Exception => e
			nil
		end
	end
end