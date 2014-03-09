require 'open-uri'
require 'hpricot'

class Kinopoisk
	def self.fetch_rating_xml(id)
		# http://rating.kinopoisk.ru/535244.xml
		begin
			open('http://rating.kinopoisk.ru/' + id.to_s + '.xml').read
		rescue
			return nil
		end
	end

	def self.get_ratings(id)
		data = Kinopoisk.fetch_rating_xml(id);
		error = false;
		begin
			doc = Hpricot(data)
			kinopoisk_rating = doc.at("kp_rating").inner_text.to_f
			kinopoisk_votes = doc.at("kp_rating")["num_vote"].to_i
			imdb_rating = doc.at("imdb_rating").inner_text.to_f rescue nil
			imdb_votes = doc.at("imdb_rating")["num_vote"].to_i rescue nil
		rescue
			kinopoisk_rating, kinopoisk_votes, imdb_rating, imdb_votes = nil
			error = true;
		end
		{:error => error, :kinopoisk => {:rating => kinopoisk_rating, :votes => kinopoisk_votes}, :imdb => {:rating => imdb_rating, :votes => imdb_votes}}
	end
end