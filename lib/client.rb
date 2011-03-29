

require 'net/http'
require 'net/https'
require 'uri'

module ExetelSms
  class Client
    class << self
      attr_accessor :test_api
      
      def with_test_api(failmode=false)
        old_test_api = @test_api
        @test_api = failmode
        retval = yield
        @test_api = old_test_api
        retval
      end
      
      def test_api?
        !@test_api.nil?
      end
    
      def fake_response(url)
        @counter = (@counter || 0) + 1
        if url.match(/\/#{Sender.api_path}\?/)
          test_api != false ? raise(Timeout::Error.new) : "1|0412345678|#{@counter}|#{@counter}|OK"
        elsif url.match(/\/#{Receiver.api_path}\?/)
          test_api != false ? '2||||No results returned|' : "1|#{@counter}|0412345678|2011-03-29 23:15:03|OK|Test message"
        elsif url.match(/\/#{Retriever.api_path}\?/) && (referencenumber = url.match(/referencenumber=(.*)/))
          test_api != false ? "1|#{@counter}|#{referencenumber}|0412987654|0412345678||Failed|0.05|OK" : "1|#{@counter}|#{referencenumber}|0412987654|0412345678|2011-03-29 23:15:03|Delivered|0.05|OK"
        elsif url.match(/\/#{Deleter.api_path}\?/)
          test_api != false ? '2|No results returned' : "1|OK"
        elsif url.match(/\/#{CreditCheck.api_path}\?/)
          test_api != false ? '1|0|OK' : '1|100|OK'
        else
          raise "ExetelSMS test API: Unknown URL"
        end.split('|',-1).map {|str| str.strip }
      end
    
      def request(url)
        return fake_response(url) if test_api?
      
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
        raise "ExetelSms::Client: No valid body found: #{body.inspect}" unless body && body =~ /|/
        body.chomp.gsub(/<br>$/i, '').split('|',-1).map {|str| str.strip }
      end
    end
  end
end
