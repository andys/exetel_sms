
module ExetelSms
  
  class Sender
    extend ExetelSms::ClassMethods
  
    attr_reader :config
    def initialize(config)
      @config = config
    end
    
    def send(to_mobile_number, msg, from_mobile_number, reference_number)
      url = self.class.build_url(
        :username => @config.username,
        :password => @config.password,
        :sender => from_mobile_number,
        :message => msg,
        :messagetype => 'Text',
        :referencenumber => reference_number,
        :mobilenumber => to_mobile_number
      )
      
      self.class.response_to_hash(ExetelSms::Client.request(url))
    end
    
    class << self
      
      def response_fields
        [:status, :to_mobile_number, :reference_number, :exetel_id, :notes]
      end
      
      def request_fields
        [:username, :password, :mobilenumber, :message, :sender, :messagetype, :referencenumber]
      end

      def exetel_url
        'https://www.exetel.com.au/sendsms/api_sms.php?'
        #username=xxxxxxxx&password=xxxxxxxx&mobilenumber=xxxxxxxx&message=xxxxxxxx&sender=xxxxxxxxx&messagetype=Text&referencenumber=xxxxxx'
      end

    end
  end
end
