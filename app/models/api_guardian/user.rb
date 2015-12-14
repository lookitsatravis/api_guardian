module ApiGuardian
  class User < ActiveRecord::Base
    acts_as_paranoid
    has_secure_password
    has_one_time_password

    belongs_to :role, class_name: ApiGuardian.configuration.role_class.to_s
    has_many :identities, class_name: ApiGuardian.configuration.identity_class.to_s

    delegate :can?, :cannot?, to: :role

    validates :email, uniqueness: true, allow_nil: true
    validates :email, presence: true, unless: Proc.new { |u| u.phone_number.present? }
    validates :phone_number, uniqueness: true, case_sensitive: false, allow_nil: true
    validates :phone_number, presence: true, unless: Proc.new { |u| u.email.present? }
    validates_with ApiGuardian::Validators::PasswordLengthValidator, if: :password
    validates_with ApiGuardian::Validators::PasswordScoreValidator, if: :password

    before_save :enforce_email_case

    # Class Methods
    def self.policy_class
      ApiGuardian::Policies::UserPolicy
    end

    # Instance Methods
    def reset_password_token_valid?
      !reset_password_sent_at.nil? && 24.hours.ago <= reset_password_sent_at
    end

    def enforce_email_case
      self.email = self.email.downcase if self.email
    end
  end
end
