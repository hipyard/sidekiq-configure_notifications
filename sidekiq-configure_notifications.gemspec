# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/configure_notifications'
require 'sidekiq/configure_notifications/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-configure_notifications"
  spec.version       = Sidekiq::ConfigureNotifications::VERSION
  spec.authors       = ["Caue Guerra"]
  spec.email         = ["caueguerra@gmail.com"]
  spec.description   = %q{This plugin allows you to define after how many retries an exception should be nofitied to Honeybadger, Newrelic, etc}
  spec.summary       = %q{This plugin allows you to define after how many retries an exception should be nofitied to Honeybadger, Newrelic, etc}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'sidekiq', '~> 2.16.1'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'minitest', '~> 5'
end
