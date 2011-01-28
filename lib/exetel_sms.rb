
['client', 'class_methods', 'sender', 'config', 'receiver', 'deleter', 'retriever'].each do |x|
  require("#{File.dirname(__FILE__)}/" + x)
end

