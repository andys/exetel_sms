
module ExetelSms
  
  class Deleter
    extend ExetelSms::ClassMethods
  
    attr_reader :config
    def initialize(config)
      @config = config
    end
    
    def delete(from_mobile_number, message_id)
      url = self.class.build_url(
        :username => @config.username,
        :password => @config.password,
        :mobilenumber => from_mobile_number,
        :messageid => message_id
      )
      
      self.class.response_to_hash(ExetelSms::Client.request(url))
    end
    
    class << self
      def response_fields
        [:status, :notes]
      end
      
      def request_fields
        [:username, :password, :mobilenumber, :messageid]
      end

      def api_path
        'api_sms_mvn_delete.php'
      end
    end
  end
end
