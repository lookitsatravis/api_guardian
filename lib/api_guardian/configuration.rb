# frozen_string_literal: true

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

    AVAILABLE_2FA_METHODS = %w(sms voice google_auth email).freeze

    attr_reader :validate_password_score, :enable_2fa, :reuse_access_token, :allow_guest_authentication
    attr_writer :user_class, :role_class, :permission_class, :role_permission_class,
                :identity_class, :minimum_password_length, :jwt_secret, :jwt_secret_key_path,
                :json_api_key_transform

    def initialize
      @validate_password_score = true
      @enable_2fa = false
      @reuse_access_token = true
      @allow_guest_authentication = false
    end

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

    def minimum_password_length
      @minimum_password_length ||= 8
    end

    def validate_password_score=(value)
      fail ConfigurationError.new('validate_password_score must be a boolean!') unless [true, false].include? value
      @validate_password_score = value
    end

    def minimum_password_score
      @minimum_password_score ||= 4
    end

    def minimum_password_score=(score)
      if (0..4).cover?(score)
        if score < 3
          ApiGuardian.logger.warn 'A password score of less than 3 is not recommended.'
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
      unless value.is_a?(String) && value.present?
        fail ConfigurationError.new('otp_header_name must be a valid string!')
      end
      @otp_header_name = value
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

    def registration
      @registration_config ||= Registration.new
    end

    def allow_guest_authentication=(value)
      fail ConfigurationError.new('allow_guest_authentication must be a boolean!') unless [true, false].include? value
      @allow_guest_authentication = value
    end

    def access_token_expires_in
      @access_token_expires_in ||= 2.hours
    end

    def access_token_expires_in=(value)
      unless value.is_a? ActiveSupport::Duration
        fail ConfigurationError.new('access_token_expires_in must be a valid ActiveSupport::Duration.')
      end
      @access_token_expires_in = value

      regenerate_doorkeeper_config
    end

    def realm
      @realm ||= 'ApiGuardian'
    end

    def realm=(value)
      @realm = value.to_s

      regenerate_doorkeeper_config
    end

    def reuse_access_token=(value)
      fail ConfigurationError.new('reuse_access_token must be a boolean!') unless [true, false].include? value
      @reuse_access_token = value

      regenerate_doorkeeper_config
    end

    def jwt_issuer
      @jwt_issuer ||= "api_guardian_#{ApiGuardian::VERSION}"
    end

    def jwt_issuer=(value)
      @jwt_issuer = value.to_s

      regenerate_doorkeeper_config
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

      regenerate_doorkeeper_config
    end

    def json_api_key_transform
      @json_api_key_transform ||= :dash
    end

    def client_password_reset_url
      @client_password_reset_url ||= 'https://change-me-in-the-apiguardian-initializer.com'
    end

    def client_password_reset_url=(value)
      unless value.match? URI.regexp
        fail ConfigurationError.new("#{value} is not a valid URL for client_password_reset_url!")
      end
      @client_password_reset_url = value

      regenerate_doorkeeper_config
    end

    def on_reset_password
      @on_reset_password ||= lambda do |_user, _reset_url|
        ApiGuardian.logger.warn(
          'You need to customize ApiGuardian::Configuration#on_reset_password lambda ' +
          'to handle the password reset communication.'
        )
      end
    end

    def on_reset_password=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_reset_password = value
    end

    def on_reset_password_complete
      @on_reset_password_complete ||= lambda do |_user|
        ApiGuardian.logger.warn(
          'You need to customize ApiGuardian::Configuration#on_reset_password_complete lambda ' +
          'to handle the post password reset communication.'
        )
      end
    end

    def on_reset_password_complete=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_reset_password_complete = value
    end

    def on_password_changed
      @on_password_changed ||= lambda do |_user|
        ApiGuardian.logger.warn(
          'You need to customize ApiGuardian::Configuration#on_password_changed lambda ' +
          'to handle the post password change communication.'
        )
      end
    end

    def on_password_changed=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_password_changed = value
    end

    def after_user_registered
      @after_user_registered ||= lambda { |_user| }
    end

    def after_user_registered=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @after_user_registered = value
    end

    def on_login_success
      @on_login_success ||= lambda { |_user| }
    end

    def on_login_success=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_login_success = value
    end

    def on_login_failure
      @on_login_failure ||= lambda { |_provider, _options| }
    end

    def on_login_failure=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_login_failure = value
    end

    def on_send_otp_via_sms
      @on_send_otp_via_sms ||= lambda do |_user|
        ApiGuardian.logger.warn(
          'You need to customize ApiGuardian::Configuration#on_send_otp_via_sms lambda ' +
          'to handle sending OTP via SMS.'
        )
      end
    end

    def on_send_otp_via_sms=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_send_otp_via_sms = value
    end

    def on_send_otp_via_voice
      @on_send_otp_via_voice ||= lambda do |_user|
        ApiGuardian.logger.warn(
          'You need to customize ApiGuardian::Configuration#on_send_otp_via_voice lambda ' +
          'to handle sending OTP via voice.'
        )
      end
    end

    def on_send_otp_via_voice=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_send_otp_via_voice = value
    end

    def on_send_otp_via_email
      @on_send_otp_via_email ||= lambda do |_user|
        ApiGuardian.logger.warn(
          'You need to customize ApiGuardian::Configuration#on_send_otp_via_email lambda ' +
          'to handle sending OTP via email.'
        )
      end
    end

    def on_send_otp_via_email=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_send_otp_via_email = value
    end

    def on_phone_verified
      @on_phone_verified ||= lambda do |_user|
        ApiGuardian.logger.warn(
          'You need to customize ApiGuardian::Configuration#on_phone_verified lambda ' +
          'to handle feedback after verifying phone.'
        )
      end
    end

    def on_phone_verified=(value)
      fail ConfigurationError.new("#{value} is not a lambda") unless value.respond_to? :call
      @on_phone_verified = value
    end

    protected

    def regenerate_doorkeeper_config
      load File.join(ApiGuardian.root, 'config', 'initializers', 'doorkeeper.rb')
    end
  end
end
