# frozen_string_literal: true

module ApiGuardian
  module Policies
    class ApplicationPolicy
      attr_reader :user, :record

      def initialize(user, record)
        @user = user
        @record = record
      end

      def index?
        false
      end

      def show?
        user.can?(["#{resource_name}:read", "#{resource_name}:manage"])
      end

      def create?
        user.can?(["#{resource_name}:create", "#{resource_name}:manage"])
      end

      def new?
        create?
      end

      def update?
        user.can?(["#{resource_name}:update", "#{resource_name}:manage"])
      end

      def edit?
        update?
      end

      def destroy?
        user.can?(["#{resource_name}:delete", "#{resource_name}:manage"])
      end

      def scope
        Pundit.policy_scope!(user, record.class)
      end

      class Scope
        attr_reader :user, :scope

        def initialize(user, scope)
          @user = user
          @scope = scope
        end

        def resolve
          scope
        end
      end

      protected

      def resource_name
        return record.new.class.name.demodulize.underscore if record.respond_to? :new

        record.class.name.demodulize.underscore
      end
    end
  end
end
