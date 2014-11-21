require 'json'

module ParserBase
	def get_first_regex_match(str, regex)
		nil unless str.is_a? String
		result = str.match(regex)
		if result.nil?
			nil
		else
			result[1]
		end
	end

	def get_first_regex_match_integer(str, regex)
		get_first_regex_match(str, regex).to_i
	end

	def parse_json(data)
		begin
			return JSON.parse(data)
		rescue => e
			{}
		end
	end

end