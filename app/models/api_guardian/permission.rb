module ApiGuardian
  class Permission < ActiveRecord::Base
    has_many :role_permissions, class_name: ApiGuardian.role_permission_class.to_s
    has_many :roles, through: :role_permissions, class_name: ApiGuardian.role_class.to_s

    validates :name, uniqueness: true
    validates :name, :desc, presence: true

    # Class Methods
    def self.policy_class
      ApiGuardian::Policies::PermissionPolicy
    end
  end
end
