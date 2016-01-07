module ApiGuardian
  class Identity < ActiveRecord::Base
    include ApiGuardian::Concerns::Models::Identity
  end
end
