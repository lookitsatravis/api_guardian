module ApiGuardian
  class Organization < ApplicationRecord
    include ApiGuardian::Concerns::Models::Organization
  end
end
