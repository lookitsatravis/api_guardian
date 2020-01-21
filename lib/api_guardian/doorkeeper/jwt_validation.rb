# frozen_string_literal: true

module Doorkeeper
  module OAuth
    class PasswordAccessTokenRequest
      validate :jwt_secret, error: :invalid_grant

      def validate_jwt_secret
        # We don't want to issue a token using the default or missing JWT secret
        secret = ApiGuardian.configuration.jwt_secret
        if secret.nil? || secret == 'changeme'
          fail ApiGuardian::Errors::InvalidJwtSecret.new(
            'You must specify a JWT secret. It cannot be nil and it cannot be the default value ("changeme").'
          )
        end

        true
      end
    end
  end
end
