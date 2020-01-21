# frozen_string_literal: true

module ApiGuardian
  module Strategies
    module Registration
      class Email < Base
        provides_registration_for :email

        allowed_api_parameters :email, :password, :password_confirmation

        def register(store, attributes)
          super(attributes)
          instance = store.new(nil)
          user = instance.create(attributes)

          # TODO: put user created event onto queue

          user
        end
      end
    end
  end
end
