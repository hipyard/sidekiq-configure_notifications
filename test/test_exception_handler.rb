require 'helper'
require 'sidekiq'
require 'sidekiq/exception_handler'
require 'sidekiq/configure_notifications/exception_handler'
require 'stringio'
require 'logger'

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
    after do
      Object.send(:remove_const, "Airbrake") # HACK should probably inject Airbrake etc into this class in the future
    end

    describe "does not log" do
      before do
        class ::Airbrake
          def self.notify_or_ignore(*args)
            raise "it should not be called"
          end
        end
      end

      it "does not log when number of retries is less than log_exceptions_after" do
        Component.new.invoke_exception('log_exceptions_after' => 4, 'retry_count' => 3)
      end

      it "does not log when number of retries is bigger than log_exceptions_after and exception is not in skip_log_exceptions" do
        Component.new.invoke_exception('log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [::Exception])
      end
    end

    describe "logs" do
      before do
        ::Airbrake = Minitest::Mock.new
      end

      it "logs when number of retries is less than log_exceptions_after and exception is not in skip_log_exceptions 3" do
        ::Airbrake.expect(:notify_or_ignore,nil,[TEST_EXCEPTION,:parameters => { 'log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [ExceptionHandlerTestException] }])
        Component.new.invoke_exception('log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [ExceptionHandlerTestException])
        ::Airbrake.verify
      end

      it "logs when number of retries is less than log_exceptions_after and skip_log_exceptions is empty" do
        ::Airbrake.expect(:notify_or_ignore,nil,[TEST_EXCEPTION,:parameters => { 'log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [] }])
        Component.new.invoke_exception('log_exceptions_after' => 2, 'retry_count' => 3, 'skip_log_exceptions' => [])
        ::Airbrake.verify
      end

      it "logs when number of retries is less than log_exceptions_after and skip_log_exceptions is not given" do
        ::Airbrake.expect(:notify_or_ignore,nil,[TEST_EXCEPTION,:parameters => { 'log_exceptions_after' => 2, 'retry_count' => 3 }])
        Component.new.invoke_exception('log_exceptions_after' => 2, 'retry_count' => 3)
        ::Airbrake.verify
      end

      it "logs when log_exceptions_after is not given" do
        ::Airbrake.expect(:notify_or_ignore,nil,[TEST_EXCEPTION,:parameters => {}])
        Component.new.invoke_exception({})
        ::Airbrake.verify
      end
    end
  end
end
