require 'doorkeeper'
require 'doorkeeper/jwt'
require 'doorkeeper/grants_assertion'
require 'api_guardian/doorkeeper/helpers'
require 'api_guardian/doorkeeper/otp_validation'
require 'api_guardian/doorkeeper/jwt_validation'
require 'api_guardian/middleware/middleware'

module ApiGuardian
  Doorkeeper = ::Doorkeeper

  class Engine < ::Rails::Engine
    isolate_namespace ApiGuardian

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
      end
    end

    config.middleware.use ApiGuardian::Middleware::CatchParseErrors

    initializer 'api_guardian.doorkeeper_helpers' do
      ActiveSupport.on_load(:action_controller) do
        Doorkeeper::ApplicationMetalController.send(:include, AbstractController::Callbacks)
        Doorkeeper::ApplicationMetalController.send(:include, ActionController::Rescue)
        Doorkeeper::ApplicationMetalController.send(:include, ApiGuardian::DoorkeeperHelpers)
      end
    end
  end
end
