# frozen_string_literal: true

module ApiGuardian
  module Strategies
    module Authentication
      class Email < Base
        provides_authentication_for :email

        def authenticate(options)
          user = ApiGuardian.configuration.user_class.find_by(email: options[:email].downcase)
          super(user: user)
          user if user && user.try(:authenticate, options[:password])
        end
      end
    end
  end
end
