#coding: UTF-8
module KinopoiskParser
  class Person
    attr_accessor :id, :url, :name

    # New instance can be initialized with id(string or integer) and an optional
    # name to make it easier to differentiate KinopoiskParser::Person instances.
    #
    #   KinopoiskParser::Person.new 13180
    #
    # Request to kinopoisk is made once and on the first access to a remote data.
    #
    def initialize(id, name=nil)
      @id   = id
      @url  = "http://www.kinopoisk.ru/name/#{id}/"
      @name = name
    end

    # Returns a url to a poster
    def poster
      doc.search('#photoBlock img').first.attr 'src'
    end

    # Returns a string containing name in russian
    def name
      @name ||= doc.search('.moviename-big').text
    end

    # Returns a string containing name in english
    def name_en
	  doc.search("span[itemprop=alternativeHeadline]").text.gsub("\n", '')
    end

    # Returns a string containing partner's name
    def partner
      doc.search("//td[@class='type'][contains(text(),'супруг')]/following-sibling::*").text
    end

    # Returns a birthdate date object
    def birthdate
      Date.strptime doc.search("td.birth").first.attr 'birthdate'
    end

    # Returns a string containing birthplace
    def birthplace
      search_by_text('место рождения').split(', ').first
    end

    # Returns an array of strings containing genres
    def genres
      search_by_text('жанры').split(', ')
    end

    # Returns an array of strings containing career professions
    def career
      search_by_text('карьера').split(', ')
    end

    # Returns an integer total movie count
    def total_movies
      search_by_text('всего фильмов').to_i
    end

    # Returns an array of strings containing best movie titles
    def best_movies
      doc.search('#BestFilmList ul')[0].search('li a').map(&:text) rescue []
    end
	
	# Returns an array of strings containing best series titles
    def best_series
      doc.search('#BestFilmList ul')[1].search('li a').map(&:text) rescue []
    end

    # Returns a string containing year of first movie
    def first_movie
	  doc.search('#infoTable a[title="Первый фильм"]').text
    end

    # Returns a string containing year of last movie
    def last_movie
	  doc.search('#infoTable a[title="Последний фильм"]').text
    end

    # Returns a string containing height
    def height
      search_by_text 'рост'
    end

    private

    def doc
      @doc ||= KinopoiskParser.parse url
    end

    def search_by_text(name)
      doc.search("//td[@class='type'][text()='#{name}']/following-sibling::*").text
    end
  end
end
