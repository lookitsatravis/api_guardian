# frozen_string_literal: true

require 'active_job'
require 'action_mailer'
require 'pundit'
require 'rack/cors'
require 'kaminari'
require 'zxcvbn'
require 'phony'
require 'active_model_otp'
require 'fast_jsonapi'
require 'api_guardian/version'
require 'api_guardian/logs'
require 'api_guardian/helpers/helpers'
require 'api_guardian/configuration'
require 'api_guardian/validation'
require 'api_guardian/errors'
# require 'api_guardian/encryption'
require 'api_guardian/engine'

require 'active_support/lazy_load_hooks'

module ApiGuardian
  ActiveSupport.run_load_hooks(:api_guardian_configuration, Configuration)

  module Concerns
    module ApiErrors
      autoload :Handler, 'api_guardian/concerns/api_errors/handler'
      autoload :Renderer, 'api_guardian/concerns/api_errors/renderer'
    end

    module ApiRequest
      autoload :Validator, 'api_guardian/concerns/api_request/validator'
    end

    module Models
      autoload :User, 'api_guardian/concerns/models/user'
      autoload :Role, 'api_guardian/concerns/models/role'
      autoload :Permission, 'api_guardian/concerns/models/permission'
      autoload :RolePermission, 'api_guardian/concerns/models/role_permission'
      autoload :Identity, 'api_guardian/concerns/models/identity'
    end
  end

  module Stores
    autoload :Base, 'api_guardian/stores/base'
    autoload :UserStore, 'api_guardian/stores/user_store'
    autoload :RoleStore, 'api_guardian/stores/role_store'
    autoload :PermissionStore, 'api_guardian/stores/permission_store'
  end

  module Serializers
    autoload :Base, 'api_guardian/serializers/base'
  end

  module Policies
    autoload :ApplicationPolicy, 'api_guardian/policies/application_policy'
    autoload :PermissionPolicy, 'api_guardian/policies/permission_policy'
    autoload :RolePolicy, 'api_guardian/policies/role_policy'
    autoload :UserPolicy, 'api_guardian/policies/user_policy'
  end

  module Validators
    autoload :PasswordLengthValidator, 'api_guardian/validators/password_length_validator'
    autoload :PasswordScoreValidator, 'api_guardian/validators/password_score_validator'
  end

  module Strategies
    module Authentication
      def self.find_strategy(provider)
        strategy = Base.providers[provider.to_sym]
        fail(
          ApiGuardian::Errors::InvalidAuthenticationProvider,
          "Could not find authentication provider '#{provider}'. Available: " + Base.providers.keys.join(', ')
        ) unless strategy
        strategy
      rescue NoMethodError
        fail(
          ApiGuardian::Errors::InvalidAuthenticationProvider,
          "Could not find authentication provider '#{provider}'. Available: " + Base.providers.keys.join(', ')
        )
      end
    end

    module Registration
      def self.find_strategy(provider)
        strategy = Base.providers[provider.to_sym]
        fail(
          ApiGuardian::Errors::InvalidRegistrationProvider,
          "Could not find registration provider '#{provider}'. Available: " + Base.providers.keys.join(', ')
        ) unless strategy
        strategy
      end
    end
  end

  module Jobs
    autoload :ApplicationJob, 'api_guardian/jobs/application_job'
    autoload :SendOtp, 'api_guardian/jobs/send_otp'
  end

  class << self
    attr_accessor :current_request, :current_user
    attr_writer :configuration

    def zxcvbn_tester
      @zxcvbn_tester ||= ::Zxcvbn::Tester.new
    end

    def root
      spec = Gem::Specification.find_all_by_name('api_guardian').first
      spec.gem_dir
    end
  end

  module_function

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield(configuration)
  end

  def logger
    @logger ||= ApiGuardian::Logging::Logger.new(STDOUT)
  end

  def class_exists?(class_name)
    class_name.constantize.is_a?(Class)
  rescue
    false
  end

  def find_user_store
    store = nil

    # Check for app-specfic store
    if ApiGuardian.class_exists?('UserStore')
      store = 'UserStore'
    end

    # Check for ApiGuardian Store
    unless store
      store = 'ApiGuardian::Stores::UserStore'
    end

    store.constantize
  end
end

require 'api_guardian/strategies/authentication/authentication'
require 'api_guardian/strategies/registration/base'
require 'api_guardian/strategies/registration/email'
