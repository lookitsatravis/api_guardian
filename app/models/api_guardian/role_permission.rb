module ApiGuardian
  class RolePermission < ApplicationRecord
    include ApiGuardian::Concerns::Models::RolePermission
  end
end
