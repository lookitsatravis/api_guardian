require 'api_guardian/strategies/authentication/password'
require 'api_guardian/strategies/authentication/two_factor'
require 'api_guardian/strategies/authentication/digits'

module ApiGuardian

  module_function

  def authenticate(username, password)
    if Helpers.email_address? username
      user = ApiGuardian.configuration.user_class.find_by(email: username)
      return Strategies::Authentication::Password.authenticate(user, password)
    elsif Helpers.phone_number? username
      user = ApiGuardian.configuration.user_class.find_by(phone_number: username)
      return Strategies::Authentication::Digits.authenticate(user, password)
    end

    nil
  end

  module Strategies
    module Authentication
    end
  end
end
