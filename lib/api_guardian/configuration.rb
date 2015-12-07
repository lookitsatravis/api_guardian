module ApiGuardian
  class Configuration
    class ConfigurationError < RuntimeError
    end

    attr_writer :user_class, :role_class, :permission_class, :role_permission_class,
                :minimum_password_length, :twilio_id, :twilio_token

    def user_class
      klass = @user_class ||= 'ApiGuardian::User'
      klass.constantize
    end

    def role_class
      klass = @role_class ||= 'ApiGuardian::Role'
      klass.constantize
    end

    def permission_class
      klass = @permission_class ||= 'ApiGuardian::Permission'
      klass.constantize
    end

    def role_permission_class
      klass = @role_permission_class ||= 'ApiGuardian::RolePermission'
      klass.constantize
    end

    def minimum_password_length
      @minimum_password_length ||= 8
    end

    def validate_password_score
      @validate_password_score ||= true
    end

    def validate_password_score=(value)
      fail ConfigurationError.new('validate_password_score must be a boolean!') unless [true, false].include? value
      @validate_password_score = value
    end

    def minimum_password_score
      @minimum_password_score ||= 4
    end

    def minimum_password_score=(score)
      if (0..4).include?(score)
        if score < 3
          ::Rails.logger.warn '[ApiGuardian] A password score of less than 3 is not recommended.'
        end
        @minimum_password_score = score
      else
        fail ConfigurationError.new('The minimum_password_score must be an integer and between 0..4')
      end
    end

    def otp_header_name
      @otp_header_name ||= 'AG-2FA-TOKEN'
    end

    def otp_header_name=(value)
      fail ConfigurationError.new('otp_header_name must be a valid string!') unless value.is_a?(String) && value.present?
      @otp_header_name = value
    end

    def enable_2fa
      @enable_2fa ||= false
    end

    def enable_2fa=(value)
      fail ConfigurationError.new('enable_2fa must be a boolean!') unless [true, false].include? value
      @enable_2fa = value
    end

    def twilio_send_from
      fail ConfigurationError.new('You must supply your Twilio Send From Number in order to use 2FA features.') unless @twilio_send_from
      @twilio_send_from
    end

    def twilio_send_from=(phone_number)
      unless Phony.plausible? phone_number
        fail ConfigurationError.new("twilio_send_from value '#{phone_number}' is not a valid phone number and is required for 2FA.")
      end
      @twilio_send_from = Phony.normalize(phone_number)
    end

    def twilio_id
      fail ConfigurationError.new('You must supply your Twilio SID in order to use 2FA features.') unless @twilio_id
      @twilio_id
    end

    def twilio_token
      fail ConfigurationError.new('You must supply your Twilio Auth Token in order to use 2FA features.') unless @twilio_token
      @twilio_token
    end
  end
end
