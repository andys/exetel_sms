
module ExetelSms
  
  class CreditCheck
    extend ExetelSms::ClassMethods
  
    attr_reader :config
    def initialize(config)
      @config = config
    end
    
    def get_credit_limit
      url = self.class.build_url(
        :username => @config.username,
        :password => @config.password
      )
      
      self.class.response_to_hash(ExetelSms::Client.request(url))
    end
    
    class << self
      def response_fields
        [:status, :limit, :notes]
      end
      
      def request_fields
        [:username, :password]
      end

      def api_path
        'api_sms_credit.php'
      end
    end
  end
end
