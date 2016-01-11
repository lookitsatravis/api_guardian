module ApiGuardian
  class Organization < ActiveRecord::Base
    include ApiGuardian::Concerns::Models::Organization
  end
end
