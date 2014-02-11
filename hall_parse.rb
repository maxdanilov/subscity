require "json"

data = File.read("hall.js")

def parse_prices(data)
	inf = 10**9
	fee = 1.1

	min_price = 10**9#Float::INFINITY
	max_price = 0

	parsed = JSON.parse(data)
	parsed["OrderZones"].each do |order_zone|
		order_zone["Orders"].each do |order|
			price = order["Price"]
			price = price / fee if order["HasFee"]
			max_price = price if price > max_price
			min_price = price if price < min_price
		end
	end
	max_price, min_price = max_price.to_i, min_price.to_i
end

puts parse_prices(data)
