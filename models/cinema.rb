class Cinema < ActiveRecord::Base
	belongs_to :city, primary_key: "city_id"
	has_many :screenings, primary_key: "cinema_id"
	has_many :movies, through: :screenings, primary_key: "cinema_id"

	validates :cinema_id,   presence: true, uniqueness: true
	validates :name,  		presence: true
	validates :city_id, 	presence: true
	
	def self.update_all
		page_size = KassaFetcher::PAGE_SIZE
		
		updated_count = 0
		fetched_count = 0
		items_count = 0
		page_count = 0
		
		City.all.map(&:city_id).each do |city_id|
			items_count = 0
			page_count = 0

			loop do 
				source = KassaFetcher.fetch_cinemas(page_count * page_size, page_size, city_id)
				parsed = KassaParser.parse_json(source)
				
				items = parsed["Items"]
				
				items.each do |item|
					c = Cinema.new(cinema_id: item["PlaceID"], city_id: city_id, name: item["Name"], address: item["Address"], metro: item["Metro"])
					if c.valid?
						c.save
						updated_count += 1
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
