module ApiGuardian
  module DoorkeeperHelpers
    extend ActiveSupport::Concern

    included do
      include ApiGuardian::Concerns::ApiErrors::Handler

      rescue_from ApiGuardian::Errors::TwoFactorRequired, with: :two_factor_required

      append_before_filter :set_current_request

      def set_current_request
        ApiGuardian.current_request = request
      end
    end
  end
end
