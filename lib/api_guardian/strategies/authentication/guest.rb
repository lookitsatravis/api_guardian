# frozen_string_literal: true

module ApiGuardian
  module Strategies
    module Authentication
      class Guest < Base
        provides_authentication_for :guest

        def authenticate(_options = {})
          unless ApiGuardian.configuration.allow_guest_authentication
            fail ApiGuardian::Errors::GuestAuthenticationDisabled
          end

          attributes = {
            email: generate_guest_email,
            password: generate_password
          }

          store = ApiGuardian::Stores::UserStore.new(nil)
          user = store.create(attributes)
          super(user: user)
          user
        end

        protected

        def generate_guest_email
          "guest_#{Time.now.to_i}#{rand(100)}@application-guest.com"
        end

        def generate_password
          SecureRandom.hex(16)
        end
      end
    end
  end
end
