# frozen_string_literal: true

module ApiGuardian
  module Stores
    class Base
      delegate :new, to: :resource_class

      attr_reader :scope

      def initialize(scope = nil)
        @scope = scope
      end

      def set_policy_scope(scope = nil)
        @scope = scope
      end

      def all
        scope.all
      end

      def paginate(page = 1, per_page = 25)
        scope.page(page).per(per_page)
      end

      def find(id)
        record = resource_class.find(id)
        fail ActiveRecord::RecordNotFound unless record
        record
      end

      def save(resource)
        resource.save!
      end

      def create(attributes)
        resource = resource_class.new(attributes)
        fail ActiveRecord::RecordInvalid.new(resource), '' unless resource.valid?
        save(resource)
        resource
      end

      def update(resource, attributes)
        resource.update_attributes!(attributes)
        resource
      end

      def destroy(resource)
        resource.destroy!
      end

      protected

      def resource_class
        @resource_class ||= find_resource_class
      end

      def find_resource_class
        class_name = self.class.name.gsub('Stores::', '').gsub('Store', '').classify

        if class_name.include? 'ApiGuardian::'
          class_name = ApiGuardian.configuration.send(class_name.gsub('ApiGuardian::', '').underscore + '_class').to_s
        end

        class_name.constantize
      end
    end
  end
end
