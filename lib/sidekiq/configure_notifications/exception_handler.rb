require 'sidekiq'

module Sidekiq
  module ExceptionHandler
    alias_method :handle_exception_original, :handle_exception

    def handle_exception(ex, msg)
      if msg['retry_count'].to_i >= msg['log_exceptions_after'].to_i &&
          (msg['skip_log_exceptions'].nil? || msg['skip_log_exceptions'].size == 0 || msg['skip_log_exceptions'].include?(ex.class))
        handle_exception_original(ex, msg)
      end
    end
  end
end
