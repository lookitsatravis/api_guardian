module ApiGuardian
  module Stores
    class Base
      @@instance = nil

      delegate :new, to: :resource_class

      def initialize(scope = nil)
        @scope = scope
        @@instance = self
      end

      def all
        @scope.all
      end

      def paginate(page = 1, per_page = 25)
        @scope.page(page).per(per_page)
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
      end

      def destroy(resource)
        resource.destroy!
      end

      protected

      def resource_class
        @resource_class ||= self.class.name.gsub('Stores::', '').gsub('Store', '').classify.constantize
      end
    end
  end
end
