require 'rails-api'
require 'doorkeeper'
require 'doorkeeper-jwt'
require 'pundit'
require 'paranoia'
require 'rack/cors'
require 'kaminari'
require 'zxcvbn'
require 'active_model_serializers'
require 'api_guardian/configuration'
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
  end

  module Errors
    autoload :InvalidContentTypeError, 'api_guardian/errors/invalid_content_type_error'
    autoload :InvalidPermissionNameError, 'api_guardian/errors/invalid_permission_name_error'
    autoload :InvalidRequestBodyError, 'api_guardian/errors/invalid_request_body_error'
    autoload :InvalidRequestResourceIdError, 'api_guardian/errors/invalid_request_resource_id_error'
    autoload :InvalidRequestResourceTypeError, 'api_guardian/errors/invalid_request_resource_type_error'
    autoload :InvalidUpdateActionError, 'api_guardian/errors/invalid_update_action_error'
    autoload :ResetTokenExpiredError, 'api_guardian/errors/reset_token_expired_error'
    autoload :ResetTokenUserMismatchError, 'api_guardian/errors/reset_token_user_mismatch_error'
  end

  module Stores
    autoload :Base, 'api_guardian/stores/base'
    autoload :UserStore, 'api_guardian/stores/user_store'
    autoload :RoleStore, 'api_guardian/stores/role_store'
    autoload :PermissionStore, 'api_guardian/stores/permission_store'
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

  class << self
    attr_writer :configuration

    def zxcvbn_tester
      @zxcvbn_tester ||= ::Zxcvbn::Tester.new
    end
  end

  module_function
  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield(configuration)
  end
end
