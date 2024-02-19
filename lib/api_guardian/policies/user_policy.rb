# frozen_string_literal: true

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

      def add_phone?
        update?
      end

      def verify_phone?
        update?
      end

      def change_password?
        update?
      end
    end
  end
end
