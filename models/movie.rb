class Movie < ActiveRecord::Base
	has_many :screenings, primary_key: "movie_id"
	has_many :cinemas, through: :screenings, primary_key: "movie_id"
	
	validates :name,  		presence: true
	validates :movie_id, 	presence: true, uniqueness: true

	def self.in_db?(id)
		Movie.where("movie_id = #{id}").size > 0
	end

	def self.get_movie(id)
		Movie.where("movie_id = #{id}").first
	end

	def self.upd_thumbnail(url)
		url.gsub("48x72", "144x212") # too small posters in mobile version
	end

	def self.update_all
		page_size = KassaFetcher::PAGE_SIZE
		
		updated_count = 0
		fetched_count = 0
		items_count = 0
		page_count = 0

		#mark all movies in the base as inactive
		Movie.all.each { |m| m.update_attribute(:active, false) }
		
		City.all.map(&:city_id).each do |city_id|
		#[2].each do |city_id|
			items_count = 0
			page_count = 0

			loop do 
				source = KassaFetcher.fetch_movies(page_count * page_size, page_size, city_id)
				parsed = KassaParser.parse_json(source)
				
				items = parsed["Items"]
				
				items.each do |item|

					c = Movie.new(	movie_id: item["objectId"], 
									name: item["name"], 
									age_restriction: item["ageRestriction"], 
									country: item["country"], 
									year: item["productionYear"], 
									genres: item["visibleTagsString"], 
									thumbnail: upd_thumbnail(item["thumbnail"]), 
									active: true, 
									duration: item["duration"] )

					if in_db?(c.movie_id)
						#mark as active in db
						get_movie(c.movie_id).update_attribute(:active, true)
					else
						#add to db
						if c.valid?
							c.save
							updated_count += 1
						end
					end
				end
				
				items_count += items.size
				fetched_count += items.size
				total_count ||= parsed["TotalCount"]
				
				page_count += 1
				
				break if items_count >= total_count
			end
		end

		return fetched_count, updated_count
	end
end
