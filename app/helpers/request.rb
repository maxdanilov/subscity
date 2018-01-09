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

    def get_subdomain
      'msk' # a fallback subdomain
    end

    def subdomain_exits?(subdomain)
      City.pluck(:domain).include? subdomain
    end

    def subdomain_valid?
      return false if subdomains.size != 1
      subdomain_exits?(subdomains.first)
    end

    def url_without_subdomain
        "#{full_domain_name}#{path}"
    end

    def url_complete
      "#{full_domain_name(subdomains.first)}#{path}"
    end
  end
end

def domain_name
  DOMAIN_NAME
end

def protocol
  PROTOCOL
end

def port
  PORT
end

def full_domain_name(subdomain=nil)
  port_suffix = [80, 443].include?(port.to_i) ? "" : ":#{port}"
  "#{protocol}://#{[subdomain, domain_name].select { |i| !i.nil? }.join('.')}#{port_suffix}"
end

def redirect_globally(subdomain = nil, path = nil)
    redirect("#{full_domain_name(subdomain)}#{path}")
end

def pre_redirect
    redirect_globally(request.get_subdomain, request.path) unless request.subdomain_valid?
end
