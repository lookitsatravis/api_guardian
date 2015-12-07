# TODO: How can we remove dependency on .new?
module ApiGuardian
  module Stores
    class UserStore < Base
      def find_by_email(email)
        ApiGuardian.configuration.user_class.find_by_email(email)
      end

      def find_by_reset_password_token(token)
        ApiGuardian.configuration.user_class.find_by_reset_password_token(token)
      end

      def create(attributes)
        attributes[:role_id] = ApiGuardian::Stores::RoleStore.default_role.id
        attributes[:email_confirmed_at] = DateTime.now.utc
        attributes[:active] = true
        super attributes
      end

      def self.register(attributes)
        instance = new(nil)

        attributes[:role_id] = ApiGuardian::Stores::RoleStore.default_role.id
        attributes[:active] = false

        # create user
        user = instance.new(attributes)
        fail ActiveRecord::RecordInvalid.new(user), '' unless user.valid?
        instance.save(user)

        # TODO: put user created event onto queue

        user
      end

      def self.reset_password(email)
        instance = new(nil)

        user = instance.find_by_email(email)

        if user
          user.reset_password_token = SecureRandom.hex(64)
          user.reset_password_sent_at = DateTime.now.utc
          user.save

          # TODO: email password reset
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
          fail ApiGuardian::Errors::ResetTokenUserMismatchError,
               attributes[:email] unless user.email == attributes[:email]

          # Check that it hasn't expired
          fail ApiGuardian::Errors::ResetTokenExpiredError, '' unless user.reset_password_token_valid?

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

          # TODO: send password changed confirmation email

          return true
        end
        false
      end
    end
  end
end
