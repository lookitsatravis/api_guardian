require 'active_support/concern'

module ApiGuardian
  module Concerns
    module Models
      module Role
        extend ActiveSupport::Concern

        included do
          self.table_name = 'api_guardian_roles'

          has_many :users, class_name: ApiGuardian.configuration.user_class.to_s
          has_many :role_permissions, class_name: ApiGuardian.configuration.role_permission_class.to_s

          validates :name, uniqueness: true, presence: true
          validates :default, uniqueness: true, if: proc { |r| r.default? }

          scope :default, -> { where(default: true) }

          # Class Methods
          def self.default_role
            default.first
          end

          def self.policy_class
            ApiGuardian::Policies::RolePolicy
          end

          # Instance Methods
          def can?(action)
            if action.is_a?(Array)
              grants = []
              action.each do |a|
                perm = ApiGuardian.configuration.permission_class.find_by_name(action)
                fail ApiGuardian::Errors::InvalidPermissionName, "Permission '#{a}' is not valid." unless perm

                role_permissions.includes(:permission).find_each do |rp|
                  grants.push rp.granted if rp.permission.name == a
                end
              end
              return grants.include? true if grants.count > 0 # otherwise this permission wasn't found at all
            else
              perm = ApiGuardian.configuration.permission_class.find_by_name(action)
              fail ApiGuardian::Errors::InvalidPermissionName, "Permission '#{action}' is not valid." unless perm

              role_permissions.includes(:permission).find_each do |rp|
                return rp.granted if rp.permission.name == action
              end
            end

            false
          end

          def cannot?(action)
            !can? action
          end

          def permissions
            arr = role_permissions.includes(:permission).map do |rp|
              rp.permission.name if rp.granted
            end.compact

            # We want to simplify returned permissions when user has "manage" for a
            # given resource by only returing that one instead of individual ones.
            arr.map do |p|
              val = nil
              if p.include? ':manage'
                val = p
              else
                resource = p.split(':')[0]
                val = p unless arr.include? "#{resource}:manage"
              end
              val
            end.compact
          end

          def create_default_permissions(granted)
            ApiGuardian.configuration.permission_class.find_each do |p|
              role_permissions.create(permission: p, granted: granted) unless role_permissions.include? p
            end
          end

          def add_permission(name)
            perm = ApiGuardian.configuration.permission_class.find_by_name(name)
            fail ApiGuardian::Errors::InvalidPermissionName, "Permission '#{name}' is not valid." unless perm

            role_permissions.each do |rp|
              return rp.update_attribute(:granted, true) if rp.permission.name == name
            end

            role_permissions.create(permission: perm, granted: true)
          end

          def remove_permission(name, destroy = false)
            role_permissions.each do |rp|
              next unless rp.permission.name == name
              if destroy
                rp.destroy
              else
                rp.update_attribute(:granted, false)
              end
            end
          end
        end
      end
    end
  end
end
