require 'nokogiri'
require 'httpclient'
require_relative 'kinopoisk_parser/movie'
require_relative 'kinopoisk_parser/search'
require_relative 'kinopoisk_parser/person'

module KinopoiskParser
  SEARCH_URL = "http://www.kinopoisk.ru/index.php?kp_query="
  NotFound   = Class.new StandardError

  # Headers are needed to mimic proper request so kinopoisk won't block it
  def self.fetch(url)
    HTTPClient.new.get url, nil, { 'User-Agent'=>'a', 'Accept-Encoding'=>'a' }
  end

  # Returns a nokogiri document or an error if fetch response status is not 200
  def self.parse(url)
    p = fetch url
    p.status==200 ? Nokogiri::XML.parse(p.body.encode('utf-8')) : raise(NotFound)
  end
end
