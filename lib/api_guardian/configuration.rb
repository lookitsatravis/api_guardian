require 'uri'

module ApiGuardian
  class Configuration
    class Registration
      def add_config_option(key)
        self.class.class_eval { attr_accessor key.to_sym }
      end
    end

    class ConfigurationError < RuntimeError
    end

    AVAILABLE_2FA_METHODS = %w(sms voice google_auth email)

    attr_writer :user_class, :role_class, :permission_class, :role_permission_class,
                :identity_class, :organization_class, :minimum_password_length,
                :twilio_id, :twilio_token, :mail_from_address, :jwt_secret,
                :jwt_secret_key_path

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

    def identity_class
      klass = @identity_class ||= 'ApiGuardian::Identity'
      klass.constantize
    end

    def organization_class
      klass = @organization_class ||= 'ApiGuardian::Organization'
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
          ApiGuardian.logger.warn 'A password score of less than 3 is not recommended.'
        end
        @minimum_password_score = score
      else
        fail ConfigurationError.new('The minimum_password_score must be an integer and between 0..4')
      end
    end

    def mail_from_address
      @mail_from_address ||= 'change-me@example.com'
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

    def available_2fa_methods
      @available_2fa_methods ||= AVAILABLE_2FA_METHODS
    end

    def available_2fa_methods=(value)
      fail ConfigurationError.new('available_2fa_methods must be an array!') unless value.is_a? Array
      allowed_methods = AVAILABLE_2FA_METHODS
      value.each do |method|
        fail ConfigurationError.new(
          "'#{method}' is not an acceptable 2FA method! Possible values: " +
          allowed_methods.join(', ')
        ) unless allowed_methods.include? method
      end
      @available_2fa_methods = value
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

    def registration
      @registration_config ||= Registration.new
    end

    def access_token_expires_in
      @access_token_expires_in ||= 2.hours
    end

    def access_token_expires_in=(value)
      unless value.is_a? ActiveSupport::Duration
        fail ConfigurationError.new('access_token_expires_in must be a valid ActiveSupport::Duration.')
      end
      @access_token_expires_in = value
    end

    def realm
      @realm ||= 'ApiGuardian'
    end

    def realm=(value)
      @realm = value.to_s
    end

    def jwt_issuer
      @jwt_issuer ||= "api_guardian_#{ApiGuardian::VERSION}"
    end

    def jwt_issuer=(value)
      @jwt_issuer = value.to_s
    end

    def jwt_secret
      @jwt_secret ||= 'changeme'
    end

    def jwt_secret_key_path
      @jwt_secret_key_path ||= nil
    end

    def jwt_encryption_method
      @jwt_encryption_method ||= :hs256
    end

    def jwt_encryption_method=(value)
      valid_methods = [:none, :hs256, :hs384, :hs512, :rs256, :rs384, :rs512, :es256, :es384, :es512]
      unless valid_methods.include? value
        fail ConfigurationError.new("#{value} is not a valid encryption method. See https://github.com/jwt/ruby-jwt")
      end
      @jwt_encryption_method = value
    end

    def client_password_reset_url
      @client_password_reset_url ||= 'https://change-me-in-the-apiguardian-initializer.com'
    end

    def client_password_reset_url=(value)
      fail ConfigurationError.new("#{value} is not a valid URL for client_password_reset_url!") unless value =~ URI.regexp
      @client_password_reset_url = value
    end
  end
end
