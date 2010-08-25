
require 'uri'

module ExetelSms
  module ClassMethods
    def new_reference_number(ident='')
      @@counter ||= 0
      @@counter += 1
      ident + ('%04X%02X%04X' % [Time.now.to_i, $$, @@counter])
    end
    
    def build_url(params_hash)
      exetel_url + request_fields.map do |field|
        raise "Missing field: #{field}" unless params_hash.has_key?(field)
        encode(field.to_s) + '=' + encode(params_hash[field].to_s)
      end.join('&')
    end
          
    def encode(str)
      URI.encode(URI.encode(str), /=|&|\?/)
    end
    
    def response_to_hash(fields)
      raise 'Missing fields in response body' unless fields.length >= response_fields.length
      ret = {}
      response_fields.each {|field| ret[field] = fields.shift }
      ret[:other] = fields
      ret
    end
      
  end
end
