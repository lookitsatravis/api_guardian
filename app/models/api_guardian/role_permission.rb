module ApiGuardian
  class RolePermission < ActiveRecord::Base
    include ApiGuardian::Concerns::Models::RolePermission
  end
end
