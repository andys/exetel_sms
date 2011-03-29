
module ExetelSms
  class Config
  
    attr_reader :username, :password, :mvn
    
    def initialize(username, password, mvn=nil)
      @username = username
      @password = password
      @mvn = mvn
    end  
    
  end
end
