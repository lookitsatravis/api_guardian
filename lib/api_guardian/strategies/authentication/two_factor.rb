# frozen_string_literal: true

module ApiGuardian
  module Strategies
    module Authentication
      class TwoFactor
        def self.authenticate_request(user, request)
          return true unless ApiGuardian.configuration.enable_2fa

          if user.otp_enabled
            otp_header_name = ApiGuardian.configuration.otp_header_name
            otp_code = request.headers[otp_header_name]

            if !otp_code || otp_code.blank?
              ApiGuardian.logger.warn 'OTP not provided'
              ApiGuardian::Jobs::SendOtp.perform_later user
              fail ApiGuardian::Errors::TwoFactorRequired
            end

            valid = user.authenticate_otp otp_code, drift: 30
            ApiGuardian.logger.warn 'OTP code invalid' unless valid
            return valid
          end

          true
        end
      end
    end
  end
end
