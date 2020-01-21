# frozen_string_literal: true

require 'active_support/concern'

module ApiGuardian
  module Concerns
    module Models
      module RolePermission
        extend ActiveSupport::Concern

        included do
          self.table_name = 'api_guardian_role_permissions'

          belongs_to :role, class_name: ApiGuardian.configuration.role_class.to_s
          belongs_to :permission, class_name: ApiGuardian.configuration.permission_class.to_s

          validates :role_id, uniqueness: { scope: :permission_id, message: 'Permission combination already exists!' }
        end
      end
    end
  end
end
