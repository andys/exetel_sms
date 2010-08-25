

require 'net/http'
require 'net/https'
require 'uri'

module ExetelSms
  class Client
    class << self
    
      def request(url)
        uri = URI.parse(url)
        h = Net::HTTP.new(uri.host, uri.port)
        h.use_ssl = true
        h.verify_mode = OpenSSL::SSL::VERIFY_NONE
        #h.set_debug_output $stderr
        body = ''
        h.start do |http|
          response = http.request_get(uri.request_uri)
          body = response.body
        end
        raise "No body" unless body && body =~ /|/
        body.chomp.gsub(/<br>$/i, '').split('|').map {|str| str.strip }
      end
    end
  end
end
