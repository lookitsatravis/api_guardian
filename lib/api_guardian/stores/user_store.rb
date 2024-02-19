# frozen_string_literal: true

# TODO: How can we remove dependency on .new?
module ApiGuardian
  module Stores
    class UserStore < Base
      def find_by_email(email)
        ApiGuardian.configuration.user_class.find_by_email(email.downcase)
      end

      def find_by_reset_password_token(token)
        ApiGuardian.configuration.user_class.find_by_reset_password_token(token)
      end

      def create(attributes, options = {})
        defaults = {
          confirm_email: true
        }

        options = defaults.merge(options)

        attributes[:role_id] = ApiGuardian::Stores::RoleStore.default_role.id
        attributes[:email_confirmed_at] = DateTime.now.utc if options[:confirm_email]
        attributes[:active] = true
        super attributes
      end

      def create_with_identity(attributes, id_attributes, create_options)
        user = create(attributes, create_options)
        user.identities.create!(id_attributes)
        user
      end

      def add_phone(user, attributes)
        check_password user, attributes

        phone_number = attributes[:phone_number]
        cc = attributes[:country_code] || '1'
        formatted_phone = Phony.normalize(phone_number, cc: cc)
        unless Phony.plausible? formatted_phone
          fail ApiGuardian::Errors::PhoneNumberInvalid
        end

        user.otp_enabled = true
        user.phone_number = formatted_phone
        user.phone_number_confirmed_at = nil
        user.save!

        ApiGuardian::Jobs::SendOtp.perform_later user, true

        user
      end

      def verify_phone(user, attributes)
        if user.authenticate_otp attributes[:otp], drift: 30
          user.phone_number_confirmed_at = DateTime.now.utc
          user.save

          ApiGuardian.configuration.on_phone_verified.call(user)

          return true
        end

        false
      end

      def change_password(user, attributes)
        # Validate current password
        check_password user, attributes

        # Update the user's password
        user.assign_attributes({
          password: attributes[:new_password],
          password_confirmation: attributes[:new_password_confirmation]
        })
        user.save! # This will fail if it is invalid

        # Finally initate notification if necessary
        ApiGuardian.configuration.on_password_changed.call(user)

        user
      end

      def self.register(attributes)
        provider = attributes.extract!(:type).fetch(:type)
        strategy = ApiGuardian::Strategies::Registration.find_strategy provider
        user = strategy.register(self, attributes)

        # If this is a new user, execute after register lambda
        # This won't be the case if register is called and an existing user was found and returned.
        unless user.previous_changes[:id].nil?
          ApiGuardian.configuration.after_user_registered.call(user)
        end

        user
      end

      def self.reset_password(email)
        instance = new(nil)

        user = instance.find_by_email(email)

        if user
          user.reset_password_token = SecureRandom.hex(64)
          user.reset_password_sent_at = DateTime.now.utc
          user.save

          base_reset_url = ApiGuardian.configuration.client_password_reset_url
          reset_url = "#{base_reset_url}?token=#{user.reset_password_token}"

          ApiGuardian.configuration.on_reset_password.call(user, reset_url)

          return true
        end

        false
      end

      def self.complete_reset_password(attributes)
        instance = new(nil)
        # Find user by token
        user = instance.find_by_reset_password_token(attributes[:token])

        if user
          # Validate submitted email matches token
          attributes[:email] = attributes[:email].downcase if attributes[:email].present?
          fail ApiGuardian::Errors::ResetTokenUserMismatch,
               attributes[:email] unless user.email == attributes[:email]

          # Check that it hasn't expired
          fail ApiGuardian::Errors::ResetTokenExpired, '' unless user.reset_password_token_valid?

          # Validate password
          if attributes.fetch(:password, nil).blank?
            user.errors.add(:password, :blank)
            fail ActiveRecord::RecordInvalid.new(user), ''
          end
          user.assign_attributes(attributes.slice(:password, :password_confirmation))
          user.save! # This will fail if it is invalid

          # Done
          user.reset_password_token = nil
          user.reset_password_sent_at = nil
          user.save

          ApiGuardian.configuration.on_reset_password_complete.call(user)

          return true
        end
        false
      end

      def self.find_identity_by_provider(user, provider)
        user.identities.where(provider: provider).first
      end

      def check_password(user, attributes)
        password = attributes[:password]
        if !password || password.blank?
          fail ApiGuardian::Errors::PasswordRequired
        end

        unless ApiGuardian::Strategies::Authentication::Email.new.authenticate(email: user.email, password: password)
          fail ApiGuardian::Errors::PasswordInvalid
        end
      end
    end
  end
end
