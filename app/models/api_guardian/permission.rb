module ApiGuardian
  class Permission < ActiveRecord::Base
    include ApiGuardian::Concerns::Models::Permission
  end
end
