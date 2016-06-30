module ApiGuardian
  module Strategies
    module Authentication
      class Base
        class << self
          def providers
            @@providers ||= {}
          end

          def provides_authentication_for(provider)
            providers[provider.to_sym] = new
          end
        end

        def authenticate(options = {})
          return unless options[:user]
          fail ApiGuardian::Errors::UserInactive unless options[:user].active?
        end
      end
    end
  end

  module_function

  def authenticate(provider = :email, options = nil)
    strategy = Strategies::Authentication.find_strategy provider
    ApiGuardian.logger.info "Authenticating via #{provider}"
    strategy.authenticate options
  end

  # constant-time comparison algorithm to prevent timing attacks
  def self.secure_compare(a, b)
    return false if a.blank? || b.blank? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
end

require 'api_guardian/strategies/authentication/two_factor'
require 'api_guardian/strategies/authentication/email'
require 'api_guardian/strategies/authentication/digits'
require 'api_guardian/strategies/authentication/facebook'
