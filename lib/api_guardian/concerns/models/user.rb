require 'active_support/concern'

module ApiGuardian
  module Concerns
    module Models
      module User
        extend ActiveSupport::Concern

        included do
          self.table_name = 'api_guardian_users'

          acts_as_paranoid
          acts_as_tenant :organization
          has_secure_password
          has_one_time_password

          belongs_to :role, class_name: ApiGuardian.configuration.role_class.to_s
          belongs_to :organization, class_name: ApiGuardian.configuration.organization_class.to_s
          has_many :identities, class_name: ApiGuardian.configuration.identity_class.to_s

          delegate :can?, :cannot?, to: :role

          validates :email, uniqueness: true, allow_nil: true
          validates :email, presence: true, unless: proc { |u| u.phone_number.present? }
          validates :phone_number, uniqueness: true, case_sensitive: false, allow_nil: true
          validates :phone_number, presence: true, unless: proc { |u| u.email.present? }
          validates_with ApiGuardian::Validators::PasswordLengthValidator, if: :password
          validates_with ApiGuardian::Validators::PasswordScoreValidator, if: :password

          before_save :enforce_organization
          before_save :enforce_email_case

          # Class Methods
          def self.policy_class
            ApiGuardian::Policies::UserPolicy
          end

          # Instance Methods
          def reset_password_token_valid?
            !reset_password_sent_at.nil? && 24.hours.ago <= reset_password_sent_at
          end

          protected

          def enforce_organization
            unless organization_id
              org = ApiGuardian.configuration.organization_class.first
              fail 'Organization is not set and no default exists!' unless org
              self.organization_id = org.id
            end
          end

          def enforce_email_case
            self.email = email.downcase if email
          end
        end
      end
    end
  end
end
