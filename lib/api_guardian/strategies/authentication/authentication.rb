module ApiGuardian
  module Strategies
    module Authentication
      class Base
        def self.authenticate(user)
          fail ApiGuardian::Errors::UserInactive unless user.active?
        end
      end
    end
  end

  module_function

  def authenticate(username, password)
    if Helpers.email_address? username
      ApiGuardian.logger.info 'Authenticating via email/password'
      user = ApiGuardian.configuration.user_class.find_by(email: username)
      return Strategies::Authentication::Password.authenticate(user, password)
    elsif Helpers.phone_number? username
      ApiGuardian.logger.info 'Authenticating via digits'
      user = ApiGuardian.configuration.user_class.find_by(phone_number: username)
      return Strategies::Authentication::Digits.authenticate(user, password)
    end

    nil
  end
end

require 'api_guardian/strategies/authentication/password'
require 'api_guardian/strategies/authentication/two_factor'
require 'api_guardian/strategies/authentication/digits'
