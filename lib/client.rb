

require 'net/http'
require 'net/https'
require 'uri'

module ExetelSms
  class Client
    class << self
      attr_accessor :test_api, :sent_messages
      
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
      
      def parse_url_params(url)
        Hash[
          *url.split('?').last.split('&').map do |pair|
            str1, str2 = pair.split('=',-1)
            [URI.decode(str1.to_s).to_sym, URI.decode(str2.to_s)]
          end.flatten
        ]
      end
    
      def fake_response(url)
        @counter = (@counter || 0) + 1
        if Sender.matchurl?(url)
          body = "1|0412345678|#{@counter}|#{@counter}|OK"
          if test_api == false
            @sent_messages << parse_url_params(url)
            body
          else
            raise(Timeout::Error.new)
          end
        elsif Receiver.matchurl?(url)
          test_api != false ? '2||||No results returned|' : "1|#{@counter}|0412345678|2011-03-29 23:15:03|OK|Test message"
        elsif Retriever.matchurl?(url) && (referencenumber = url.match(/referencenumber=(.*)/))
          test_api != false ? "1|#{@counter}|#{referencenumber}|0412987654|0412345678||Failed|0.05|OK" : "1|#{@counter}|#{referencenumber}|0412987654|0412345678|2011-03-29 23:15:03|Delivered|0.05|OK"
        elsif Deleter.matchurl?(url)
          test_api != false ? '2|No results returned' : "1|OK"
        elsif CreditCheck.matchurl?(url)
          test_api != false ? '1|0|OK' : '1|100|OK'
        else
          raise "#{self.class} test API: Unknown URL"
        end
      end
    
      def request(url)
        body = ''
        if test_api?
          body = fake_response(url)
        else
          uri = URI.parse(url)
          h = Net::HTTP.new(uri.host, uri.port)
          h.use_ssl = true
          h.verify_mode = OpenSSL::SSL::VERIFY_NONE
          #h.set_debug_output $stderr
          
          h.start do |http|
            response = http.request_get(uri.request_uri)
            body = response.body
          end
        end
        
        raise "ExetelSms::Client: No valid body found: #{body.inspect}" unless body && body =~ /|/
        request_to_array(body)
      end
      
      def request_to_array(body)
        body.chomp.gsub(/<br>$/i, '').split('|',-1).map {|str| str.strip }
      end
    end
    self.sent_messages ||= []
  end
end
