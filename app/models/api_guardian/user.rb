module ApiGuardian
  class User < ActiveRecord::Base
    include ApiGuardian::Concerns::Models::User
  end
end
