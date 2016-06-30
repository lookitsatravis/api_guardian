module ApiGuardian
  class Permission < ApplicationRecord
    include ApiGuardian::Concerns::Models::Permission
  end
end
