module ApiGuardian
  class Role < ActiveRecord::Base
    include ApiGuardian::Concerns::Models::Role
  end
end
