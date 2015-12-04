module ApiGuardian
  class RolePermission < ActiveRecord::Base
    belongs_to :role, class_name: ApiGuardian.configuration.role_class.to_s
    belongs_to :permission, class_name: ApiGuardian.configuration.permission_class.to_s

    validates :role_id, uniqueness: { scope: :permission_id, message: 'Permission combination already exists!' }
  end
end
