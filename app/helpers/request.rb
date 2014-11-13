# We re-open the request class to add the subdomains method
module Sinatra
  class Request
    def subdomains(tld_len=1) # we set tld_len to 1, use 2 for co.uk or similar
      # cache the result so we only compute it once.
      @env['rack.env.subdomains'] ||= lambda {
        # check if the current host is an IP address, if so return an empty array
        return [] if (host.nil? ||
                      /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
        host.split('.')[0...(1 - tld_len - 2)] # pull everything except the TLD
      }.call
    end

    def main_domain(tld_len=1)
        # returns domain.ru for *.domain.ru
        @env['rack.env.main_domain'] ||= lambda {
        return '' if (host.nil? ||
                      /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
        host.split('.')[tld_len..-1].join('.')
      }.call
    end

    def cache_key
        (subdomains.join(".") + path_info).gsub("/", "_").gsub(".", "_")
    end

    def geoip
      @geo_ip ||= GeoIP.new(File.dirname(__FILE__) + '/../../db/GeoLiteCity.dat').city(ip)
    end

    def get_city
      c = geoip

      city = c.city_name rescue nil
      region_name = c.region_name rescue nil
      country_code = c.country_code2 rescue nil
      cities = City.active.all
      cities.each do |c|
        # "Moscow; 48 RU"
        cur_city, cur_region = c.geoip.split(";")
        cur_region_name, cur_country_code = cur_region.split(" ")
        cur_city.strip!
        cur_region_name.strip!
        cur_country_code.strip!
        return c if ((city == cur_city or region_name == cur_region_name) and cur_country_code == country_code)
      end

      cities.first rescue nil
    end

    def get_subdomain
      get_city.domain rescue 'msk'
    end

    def subdomain_exits?(subdomain)
      City.pluck(:domain).include? subdomain
    end

    def subdomain_valid?
      return false if subdomains.size != 1
      subdomain_exits?(subdomains.first)
    end

    def url_without_subdomain
        # http://msk.subscity.ru/movies/555 => http://subscity.ru/movies/555
        'http://' + domain_name + path
    end
  end
end

def domain_name
    DOMAIN_NAME
end

def redirect_globally(subdomain = nil, path = nil)
    subdomain += "." unless subdomain.nil?
    redirect('http://'+ subdomain.to_s + domain_name + path.to_s)
end

def pre_redirect
    redirect_globally(request.get_subdomain, request.path) unless request.subdomain_valid? 
end
