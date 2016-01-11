module ApiGuardian
  module Strategies
    module Authentication
      class Password < Base
        def self.authenticate(user, password)
          super(user)
          user if user && user.try(:authenticate, password)
        end
      end
    end
  end
end
