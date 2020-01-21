# frozen_string_literal: true

require 'active_support/concern'

module ApiGuardian
  module Concerns
    module Models
      module User
        extend ActiveSupport::Concern

        included do
          self.table_name = 'api_guardian_users'

          has_secure_password
          has_one_time_password

          belongs_to :role, class_name: ApiGuardian.configuration.role_class.to_s
          has_many :identities, class_name: ApiGuardian.configuration.identity_class.to_s

          delegate :can?, :cannot?, to: :role

          validates :email, uniqueness: true, allow_nil: true
          validates :email, presence: true, unless: proc { |u| u.phone_number.present? }
          validates :phone_number, uniqueness: true, case_sensitive: false, allow_nil: true
          validates :phone_number, presence: true, unless: proc { |u| u.email.present? }
          validates_with ApiGuardian::Validators::PasswordLengthValidator, if: :password
          validates_with ApiGuardian::Validators::PasswordScoreValidator, if: :password

          before_save :enforce_role
          before_save :enforce_email_case

          # Class Methods
          def self.policy_class
            ApiGuardian::Policies::UserPolicy
          end

          # Instance Methods
          def authenticate(unencrypted_password)
            return false if password_digest.blank?
            bcrypt = ::BCrypt::Password.new(password_digest)
            password = ::BCrypt::Engine.hash_secret(unencrypted_password, bcrypt.salt)
            ApiGuardian.secure_compare(password, password_digest) && self
          end

          def reset_password_token_valid?
            !reset_password_sent_at.nil? && 24.hours.ago <= reset_password_sent_at
          end

          def guest?
            if email
              self.email.include? 'application-guest.com'
            else
              false
            end
          end

          protected

          def enforce_email_case
            self.email = email.downcase if email
          end

          def enforce_role
            unless role_id
              self.role_id = ApiGuardian.configuration.role_class.default_role.id
            end
          end
        end
      end
    end
  end
end
