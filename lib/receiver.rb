
require 'exetel_sms/client'
require 'exetel_sms/class_methods'

module ExetelSms
  
  class Receiver
    extend ExetelSms::ClassMethods
  
    attr_reader :config
    def initialize(config)
      @config = config
    end
    
    def receive(from_mobile_number)
      url = self.class.build_url(
        :username => @config.username,
        :password => @config.password,
        :mobilenumber => from_mobile_number
      )
      
      self.class.response_to_hash(ExetelSms::Client.request(url))
    end
    
    class << self
      
      def response_fields
        [:status, :exetel_id, :from_mobile_number, :received_at, :notes, :message]
      end
      
      def request_fields
        [:username, :password, :mobilenumber]
      end

      def exetel_url
        'https://www.exetel.com.au/sendsms/api_sms_mvn_inbox.php?'
      end

    end
  end
end
