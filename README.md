This plugin allows you to define after how many retries an exception should be nofitied to Honeybadger, Newrelic, etc

To use it, just install this gem:

```ruby
gem 'sidekiq'
gem 'sidekiq-configure_notifications'
```

Now, on your worker you can just add :log_exceptions_after => x and :skip_log_exceptions => [Exception, MyCustomError]

as in:

```ruby
class MyWorker
  include Sidekiq::Worker
  sidekiq_options :log_exceptions_after => 8, :skip_log_exceptions => [Exception, MyCustomError]

  def perform(user_id)
    raise Exception.new
  end
end
```

This code will keep retrying, but will only notify external services after 8 retries. Also, all the exceptions that are not "Exception" or "MyCustomError" will be notified as usual. If you don't use the skip_log_exceptions option, all exceptions will be only logged after 8 retries
