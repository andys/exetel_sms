
require 'test/unit'
require "./#{File.dirname(__FILE__)}/../lib/exetel_sms.rb"

class TestExetelSms < Test::Unit::TestCase

  def setup
    config = ExetelSms::Config.new('username', 'password')
    @sender = ExetelSms::Sender.new(config)
    @retriever = ExetelSms::Retriever.new(config)
    @receiver = ExetelSms::Receiver.new(config)
    @deleter = ExetelSms::Deleter.new(config)
    @credit_check = ExetelSms::CreditCheck.new(config)
  end
  
  def teardown
  end
  
  def test_credit_check_ok
    result = ExetelSms::Client.with_test_api { @credit_check.get_credit_limit }
    assert result.success?
    assert result[:limit].to_f > 0
  end

  def test_credit_check_fail
    result = ExetelSms::Client.with_test_api(:fail) { @credit_check.get_credit_limit }
    assert result.success?
    assert_equal 0, result[:limit].to_f
  end
  
  def test_sender_ok
    result = ExetelSms::Client.with_test_api { @sender.send('0412345678', 'Hello?', '0412987654', '1') }
    assert result.success?
  end

  def test_sender_exception
    assert_raises(Timeout::Error) do
      ExetelSms::Client.with_test_api(:fail) { @sender.send('0412345678', 'Hello?', '0412987654', '1') }
    end
  end

  def test_receiver_ok
    result = ExetelSms::Client.with_test_api { @receiver.receive('0412345678') }
    assert result.success?
    assert_not_equal '', result[:message]
  end

  def test_receiver_fail
    result = ExetelSms::Client.with_test_api(:fail) { @receiver.receive('0412345678') }
    assert !result.success?
    assert_equal '', result[:message]
  end

  def test_retriever_ok
    result = ExetelSms::Client.with_test_api { @retriever.check_sent('1') }
    assert result.success?
    assert_equal 'Delivered', result[:message_status]
  end

  def test_retriever_fail
    result = ExetelSms::Client.with_test_api(:fail) { @retriever.check_sent('1') }
    assert result.success?
    assert_equal 'Failed', result[:message_status]
  end

  def test_deleter_ok
    result = ExetelSms::Client.with_test_api { @deleter.delete('0412345678', '1') }
    assert result.success?
  end

  def test_deleter_fail
    result = ExetelSms::Client.with_test_api(:fail) { @deleter.delete('0412345678', '1') }
    assert !result.success?
  end
  
  
end


