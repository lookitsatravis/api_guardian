require 'active_support/concern'

module ApiGuardian
  module Concerns
    module Models
      module Organization
        extend ActiveSupport::Concern

        included do
          self.table_name = 'api_guardian_organizations'

          has_many :users, class_name: ApiGuardian.configuration.user_class.to_s
        end
      end
    end
  end
end
