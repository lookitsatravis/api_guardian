module ApiGuardian
  class Identity < ApplicationRecord
    include ApiGuardian::Concerns::Models::Identity
  end
end
