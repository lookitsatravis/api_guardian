# frozen_string_literal: true

require 'active_support/concern'

module ApiGuardian
  module Concerns
    module Models
      module Identity
        extend ActiveSupport::Concern

        included do
          self.table_name = 'api_guardian_identities'

          belongs_to :user, class_name: ApiGuardian.configuration.user_class.to_s

          validates :provider, presence: true
          validates :provider_uid, presence: true, uniqueness: {
            scope: :provider, message: 'UID already exists for this provider.'
          }
        end
      end
    end
  end
end
