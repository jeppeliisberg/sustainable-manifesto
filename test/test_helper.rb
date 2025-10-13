ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "webmock/minitest"
require "mocha/minitest"

# Allow real HTTP connections by default, except for what we explicitly stub
WebMock.disable_net_connect!(allow_localhost: true)

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Reset Rack::Attack throttle cache between tests
    setup do
      Rack::Attack.cache.store.clear if Rack::Attack.cache.store.respond_to?(:clear)
    end
  end
end
