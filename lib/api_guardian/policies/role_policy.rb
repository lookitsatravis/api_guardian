# frozen_string_literal: true

module ApiGuardian
  module Policies
    class RolePolicy < ApplicationPolicy
      class Scope < Scope
        def resolve
          if user.can?(['role:read', 'role:manage'])
            scope
          else
            fail Pundit::NotAuthorizedError
          end
        end
      end
    end
  end
end
