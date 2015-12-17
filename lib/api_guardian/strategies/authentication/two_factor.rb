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
              ApiGuardian::Jobs::SendOtp.perform_later user
              fail ApiGuardian::Errors::TwoFactorRequired
            end

            return user.authenticate_otp otp_code, drift: 30
          end

          true
        end
      end
    end
  end
end
