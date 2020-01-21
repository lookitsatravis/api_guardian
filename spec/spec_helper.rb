# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

# Setup simplecov
require 'simplecov'

SimpleCov.start do
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Serializers', 'app/serializers'
  add_group 'Engine::Concerns', 'lib/api_guardian/concerns'
  add_group 'Engine::Doorkeeper', 'lib/api_guardian/doorkeeper'
  add_group 'Engine::Errors', 'lib/api_guardian/errors'
  add_group 'Engine::Jobs', 'lib/api_guardian/jobs'
  add_group 'Engine::Mailers', 'lib/api_guardian/mailers'
  add_group 'Engine::Policies', 'lib/api_guardian/policies'
  add_group 'Engine::Stores', 'lib/api_guardian/stores'
  add_group 'Engine::Strategies', 'lib/api_guardian/strategies'
  add_group 'Engine::Validators', 'lib/api_guardian/validators'
  add_filter 'db'
  add_filter 'spec'
end

# Setup dummy Rails app and other test requirements
require File.expand_path('../dummy/config/environment.rb', __FILE__)
require 'pundit/rspec'
require 'rspec/rails'
require 'factory_bot_rails'
require 'faker'
require 'database_cleaner'
require 'shoulda/matchers'
require 'support/matchers'
require 'support/request_helpers'
require 'rspec-activemodel-mocks'
require 'generator_spec'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow: 'codeclimate.com')

Rails.backtrace_cleaner.remove_silencers!
ActiveRecord::Migration.maintain_test_schema!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include Rails.application.routes.url_helpers

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # Use color in STDOUT
  config.color = true

  # Use color not only in STDOUT but also in pagers and files
  config.tty = true

  # Use the specified formatter
  config.formatter = 'Fuubar' # :progress, :html, :textmate

  config.order = 'random'

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include FactoryBot::Syntax::Methods
  config.include Requests::JsonHelpers, type: :request
  config.include Requests::AuthHelpers, type: :request
  config.include Requests::ErrorHelpers, type: :request

  # Disable custom logger during tests
  config.before(:each) do
    logger = instance_double(ApiGuardian::Logging::Logger)
    allow(logger).to receive(:debug)
    allow(logger).to receive(:info)
    allow(logger).to receive(:warn)
    allow(logger).to receive(:error)
    allow(logger).to receive(:fatal)
    allow(ApiGuardian).to receive(:logger).and_return(logger)
  end

  # Disable Zxcvbn to improve performance
  config.before(:each) do
    allow_any_instance_of(Zxcvbn::Tester).to(
      receive(:test).and_return(OpenStruct.new({ score: 4 }))
    )
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose one or more libraries:
    with.library :rails
  end
end
