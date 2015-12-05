module ApiGuardian
  module Strategies
    class PasswordAuthentication
      def authenticate(resource, password)
        resource if resource && resource.try(:authenticate, password)
      end
    end
  end
end
