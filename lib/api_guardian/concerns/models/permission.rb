# frozen_string_literal: true

require 'active_support/concern'

module ApiGuardian
  module Concerns
    module Models
      module Permission
        extend ActiveSupport::Concern

        included do
          self.table_name = 'api_guardian_permissions'

          has_many :role_permissions, class_name: ApiGuardian.configuration.role_permission_class.to_s
          has_many :roles, through: :role_permissions, class_name: ApiGuardian.configuration.role_class.to_s

          validates :name, uniqueness: true
          validates :name, :desc, presence: true

          # Class Methods
          def self.policy_class
            ApiGuardian::Policies::PermissionPolicy
          end
        end
      end
    end
  end
end
