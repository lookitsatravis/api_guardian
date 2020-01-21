# frozen_string_literal: true

module Doorkeeper
  module OAuth
    class PasswordAccessTokenRequest
      validate :otp, error: :invalid_grant

      def validate_otp
        ApiGuardian::Strategies::Authentication::TwoFactor.authenticate_request(
          resource_owner, ApiGuardian.current_request
        )
      end
    end
  end
end
