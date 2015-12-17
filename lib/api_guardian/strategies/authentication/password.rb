module ApiGuardian
  module Strategies
    module Authentication
      class Password
        def self.authenticate(resource, password)
          resource if resource && resource.try(:authenticate, password)
        end
      end
    end
  end
end
