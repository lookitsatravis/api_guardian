# frozen_string_literal: true

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
              if action.length == 1
                single_permission_check action.first
              else
                array_permission_check action
              end
            else
              single_permission_check action
            end
          end

          def cannot?(action)
            !can? action
          end

          def permissions
            arr = role_permissions_collection.map do |rp|
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
            ApiGuardian.configuration.permission_class.all.each do |p|
              existing_permission = role_permissions.where(permission: p).first
              role_permissions.create(permission: p, granted: granted) unless existing_permission
            end
          end

          def add_permission(name)
            perm = ApiGuardian.configuration.permission_class.find_by_name(name)
            fail ApiGuardian::Errors::InvalidPermissionName, "Permission '#{name}' is not valid." unless perm

            role_permissions.includes(:permission).each do |rp|
              return rp.update_attribute(:granted, true) if rp.permission.name == name
            end

            role_permissions.create(permission: perm, granted: true)
          ensure
            @role_permissions_collection = nil
          end

          def remove_permission(name, destroy = false)
            role_permissions.includes(:permission).each do |rp|
              next unless rp.permission.name == name
              if destroy
                rp.destroy
              else
                rp.update_attribute(:granted, false)
              end
            end
          ensure
            @role_permissions_collection = nil
          end

          private

          def array_permission_check(actions)
            grants = []
            perms = load_permission(actions)

            unless perms.length > 0
              fail ApiGuardian::Errors::InvalidPermissionName, "Permissions '#{actions.join(', ')}' are not valid."
            end

            role_permissions_collection.each do |rp|
              grants.push rp.granted if actions.include?(rp.permission.name)
            end

            return grants.include? true if grants.count > 0 # otherwise this permission wasn't found at all

            false
          end

          def single_permission_check(action)
            perm = load_permission(action).first
            fail ApiGuardian::Errors::InvalidPermissionName, "Permission '#{action}' is not valid." unless perm

            role_permissions_collection.each do |rp|
              return rp.granted if rp.permission.name == action
            end

            false
          end

          def role_permissions_collection
            @role_permissions_collection ||= role_permissions.includes(:permission).all
          end

          def load_permission(name)
            # Basic caching mechanism to save on queries for a request
            @permissions = {} unless @permissions
            key = name.to_s

            if @permissions[key]
              return @permissions[key]
            end

            result = ApiGuardian.configuration.permission_class.where(name: name)

            @permissions[key] = result

            result
          end
        end
      end
    end
  end
end
