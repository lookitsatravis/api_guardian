module ApiGuardian
  class User < ApplicationRecord
    include ApiGuardian::Concerns::Models::User
  end
end
