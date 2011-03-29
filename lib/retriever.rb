
module ExetelSms
  
  class Retriever
    extend ExetelSms::ClassMethods
  
    attr_reader :config
    def initialize(config)
      @config = config
    end

    def check_sent(reference_number)
      url = self.class.build_url(
        :username => @config.username,
        :password => @config.password,
        :referencenumber => reference_number
      )
      
      self.class.response_to_hash(ExetelSms::Client.request(url))
    end
    
    class << self
      
      def response_fields
        [:status, :exetel_id, :reference_number, :sender, :to_mobile_number, :received_at, :message_status, :charge, :notes]
      end
      
      def request_fields
        [:username, :password, :referencenumber]
      end

      def api_path
        'api_sms_detail.php'
      end

    end
  end
end
