module ApiGuardian
  module Policies
    class UserPolicy < ApplicationPolicy
      class Scope < Scope
        def resolve
          if user.can?(['user:read', 'user:manage'])
            scope.includes(role: [role_permissions: [:permission]])
          else
            fail Pundit::NotAuthorizedError
          end
        end
      end

      def show?
        user.can?(['user:read', 'user:manage']) || record.id == user.id
      end

      def update?
        user.can?(['user:update', 'user:manage']) || record.id == user.id
      end
    end
  end
end
