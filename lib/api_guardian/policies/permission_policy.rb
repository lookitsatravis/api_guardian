# frozen_string_literal: true

module ApiGuardian
  module Policies
    class PermissionPolicy < ApplicationPolicy
      class Scope < Scope
        def resolve
          if user.can?(['permission:read', 'permission:manage'])
            scope
          else
            fail Pundit::NotAuthorizedError
          end
        end
      end
    end
  end
end
