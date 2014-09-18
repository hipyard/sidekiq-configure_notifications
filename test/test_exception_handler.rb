require 'helper'
require 'sidekiq'
require 'sidekiq/exception_handler'
require 'sidekiq/configure_notifications/exception_handler'

ExceptionHandlerTestException = Class.new(StandardError)
TEST_EXCEPTION = ExceptionHandlerTestException.new("Something didn't work!")

class Component
  include Sidekiq::ExceptionHandler

  def invoke_exception(args)
    raise TEST_EXCEPTION
  rescue ExceptionHandlerTestException => e
    handle_exception(e,args)
  end
end

class TestExceptionHandler < Minitest::Test
  describe "with log_exceptions_after and skip_log_exceptions options" do

    let(:error_handler) { Minitest::Mock.new }

    before { Sidekiq.error_handlers << error_handler }
    after  { Sidekiq.error_handlers.delete error_handler }

    describe "does not log" do
      it "does not log when number of retries is less than log_exceptions_after" do
        error_handler.expect :call, nil, [TEST_EXCEPTION, 'log_exceptions_after' => 4, 'retry_count' => 3]
        Component.new.invoke_exception('log_exceptions_after' => 4, 'retry_count' => 3)
        assert_raises(MockExpectationError, "It logged!") do
          error_handler.verify
        end
      end

      it "does not log when number of retries is bigger than log_exceptions_after and exception is not in skip_log_exceptions" do
        error_handler.expect :call, nil, [TEST_EXCEPTION, 'log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [::Exception]]
        Component.new.invoke_exception('log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [::Exception])
        assert_raises(MockExpectationError, "It logged!") do
          error_handler.verify
        end
      end
    end

    describe "logs" do
      it "logs when number of retries is less than log_exceptions_after and exception is not in skip_log_exceptions 3" do
        error_handler.expect :call, nil, [TEST_EXCEPTION, { 'log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [ExceptionHandlerTestException] }]
        Component.new.invoke_exception('log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [ExceptionHandlerTestException])
        error_handler.verify
      end

      it "logs when number of retries is less than log_exceptions_after and skip_log_exceptions is empty" do
        error_handler.expect :call, nil, [TEST_EXCEPTION, { 'log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [] }]
        Component.new.invoke_exception('log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [])
        error_handler.verify
      end

      it "logs when number of retries is less than log_exceptions_after and skip_log_exceptions is not given" do
        error_handler.expect :call, nil, [TEST_EXCEPTION, { 'log_exceptions_after' => 2, 'retry_count' => 3 }]
        Component.new.invoke_exception('log_exceptions_after' => 2, 'retry_count' => 3)
        error_handler.verify
      end

      it "logs when log_exceptions_after is not given" do
        error_handler.expect :call, nil, [TEST_EXCEPTION, {}]
        Component.new.invoke_exception({})
        error_handler.verify
      end
    end
  end
end
