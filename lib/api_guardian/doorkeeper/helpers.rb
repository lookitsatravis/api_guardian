# frozen_string_literal: true

module ApiGuardian
  module DoorkeeperHelpers
    extend ActiveSupport::Concern

    included do
      include ApiGuardian::Concerns::ApiErrors::Handler

      rescue_from ApiGuardian::Errors::TwoFactorRequired, with: :two_factor_required
      rescue_from ApiGuardian::Errors::InvalidJwtSecret, with: :invalid_jwt_secret
      rescue_from ApiGuardian::Errors::UserInactive, with: :user_inactive
      rescue_from ApiGuardian::Errors::InvalidAuthenticationProvider, with: :malformed_request
      rescue_from ApiGuardian::Errors::IdentityAuthorizationFailed, with: :identity_authorization_failed

      append_before_action :set_current_request

      def set_current_request
        ApiGuardian.current_request = request
      end
    end
  end
end
