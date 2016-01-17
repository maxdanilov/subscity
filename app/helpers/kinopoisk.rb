require 'open-uri'
require 'nokogiri'

class Kinopoisk
	def self.fetch_rating_xml(id)
		# http://rating.kinopoisk.ru/535244.xml
		begin
			open('http://rating.kinopoisk.ru/' + id.to_s + '.xml').read
		rescue
			return nil
		end
	end

	def self.get_imdb_rating(imdb_id)
		url = "http://www.imdb.com/title/tt#{imdb_id.to_s.rjust(8, "0")}/"
		error = false
		begin
			doc = Nokogiri::XML.parse(open(url))
			rating = doc.at("[@itemprop=ratingValue]").inner_text.to_f rescue nil
			votes = doc.at("[@itemprop=ratingCount]").inner_text.gsub(/[^0-9]/, '').to_i rescue nil
		rescue
			rating, votes = nil
			error = true;
		end
		{:error => error, :rating => rating, :votes => votes}
	end

	def self.get_kinopoisk_rating(kinopoisk_id)
		data = Kinopoisk.fetch_rating_xml(kinopoisk_id);
		error = false;
		begin
			doc = Nokogiri::XML(data)
			rating = doc.at("kp_rating").inner_text.to_f
			votes = doc.at("kp_rating")["num_vote"].to_i
			#imdb_rating = doc.at("imdb_rating").inner_text.to_f rescue nil
			#imdb_votes = doc.at("imdb_rating")["num_vote"].to_i rescue nil
		rescue
			rating, votes = nil
			error = true;
		end
		{:error => error, :rating => rating, :votes => votes}
	end

	def self.get_ratings(kinopoisk_id, imdb_id)
		kp = get_kinopoisk_rating(kinopoisk_id) rescue nil
		if imdb_id.to_i == 0
			imdb = { :error => false }
		else
			imdb = get_imdb_rating(imdb_id) rescue nil
		end
		
		error = (kp[:error] or imdb[:error]) rescue true
		kinopoisk_rating = kp[:rating] rescue nil
		kinopoisk_votes = kp[:votes] rescue nil
		imdb_rating = imdb[:rating] rescue nil
		imdb_votes = imdb[:votes] rescue nil

		{:error => error, :kinopoisk => {:rating => kinopoisk_rating, :votes => kinopoisk_votes}, :imdb => {:rating => imdb_rating, :votes => imdb_votes}}
	end

	def self.update_ratings(c)
		puts "\tUpdating rating #{c.kinopoisk_id}..."
		result = Kinopoisk.get_ratings(c.kinopoisk_id, c.imdb_id) rescue nil
		
		unless result.nil? or result[:error] == true
			r = nil
			if Rating.exists?(:movie_id => c.movie_id)
				puts "\t\t Updating a record..."
				r = Rating.where(:movie_id => c.movie_id).first
			else
				puts "\t\t Creating a record..."
				r = Rating.new(	:movie_id => c.movie_id)
			end

			r[:kinopoisk_rating] = result[:kinopoisk][:rating].to_f
			r[:kinopoisk_votes] = result[:kinopoisk][:votes].to_i
			r[:imdb_rating] = result[:imdb][:rating].to_f
			r[:imdb_votes] = result[:imdb][:votes].to_i
			r.save
			puts "\t\t Update result: #{result}..."
		else
			puts "\t\t An error occured for #{c.kinopoisk_id}..."
		end
	end

	def self.poster_url c
		return "" if c.kinopoisk_id.nil?
		"http://st.kp.yandex.net/images/film_iphone/iphone360_#{c.kinopoisk_id}.jpg"
	end

	def self.has_poster? c
		(not open(poster_url(c)).base_uri.request_uri.include? "no-poster") rescue false
	end

	def self.download_poster(c, force_rewrite = false)
		return if c.kinopoisk_id.nil?
		url = poster_url(c)
		return unless has_poster? c
		c.download_poster(url, force_rewrite)
	end
end