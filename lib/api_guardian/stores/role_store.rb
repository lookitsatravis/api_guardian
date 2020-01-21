# frozen_string_literal: true

module ApiGuardian
  module Stores
    class RoleStore < Base
      def self.default_role
        Role.default_role
      end
    end
  end
end
