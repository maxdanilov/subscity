require "uri"
require "net/http"
require "./app/helpers/logger"
require "json"
 
#sessionID:9752492
#placeCount:1
#widgetID:16857 
 
params = { 'sessionID' => 9752492, 'placeCount' => 1, 'widgetID' => 16857 }

#x = Net::HTTP.post_form(URI.parse('http://m.kassa.rambler.ru/place/hallplanajax'), params)
x = Net::HTTP.post_form(URI.parse('http://m.kassa.rambler.ru/place/hallplanajax'), params)
#Logger.put(x.body.encode("UTF-8", :invalid=>:replace, :replace=>"?"))
#puts x.body

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

puts parse_prices(x.body)