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

	def self.update_ratings(c)
		puts "\tUpdating rating #{c.kinopoisk_id}...".yellow
		result = Kinopoisk.get_ratings(c.kinopoisk_id) rescue nil
		unless result.nil? or result[:error] == true
			r = nil
			if Rating.exists?(:movie_id => c.movie_id)
				puts "\t\t Updating a record...".magenta
				r = Rating.where(:movie_id => c.movie_id).first
			else
				puts "\t\t Creating a record...".magenta
				r = Rating.new(	:movie_id => c.movie_id)
			end

			r[:kinopoisk_rating] = result[:kinopoisk][:rating]
			r[:kinopoisk_votes] = result[:kinopoisk][:votes]
			r[:imdb_rating] = result[:imdb][:rating]
			r[:imdb_votes] = result[:imdb][:votes]

			r.save
			puts "\t\t Update result: #{result}...".green
		else
			puts "\t\t An error occured for #{c.kinopoisk_id}...".red
		end
	end
end