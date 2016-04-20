module ApiGuardian
  module Strategies
    module Authentication
      class Digits < Base
        provides_authentication_for :digits

        def authenticate(auth_hash)
          # Validate auth data
          response = get_auth_response auth_hash
          return nil unless response

          # Find user by phone number
          phone_number = response['phone_number']
          user = ApiGuardian.configuration.user_class.find_by(phone_number: phone_number)
          return nil unless user

          # Verify identity exits for digits for this user and that IDs match
          identity = ApiGuardian::Stores::UserStore.find_identity_by_provider(user, :digits)
          return nil unless identity

          unless identity.provider_uid == response['id_str']
            fail(
              ApiGuardian::Errors::IdentityAuthorizationFailed,
              'An account was located with your Digits phone number, but the Digits IDs do not match.'
            )
          end

          # Verify user is active (which is all that super does)
          super(user: user)

          update_identity(identity, response)

          user
        end

        protected

        def parse_digits_data(auth_hash)
          decoded = Base64.decode64(auth_hash)
          decoded.split(';')
        end

        def get_auth_response(auth_hash)
          auth_url, auth_header = parse_digits_data(auth_hash)
          client = ApiGuardian::Helpers::Digits.new(auth_url, auth_header)
          return nil unless client.validate.succeeded
          response = client.authorize!
          JSON.parse(response.body)
        end

        def update_identity(identity, response)
          identity.update_attributes(
            tokens: response['access_token']
          )
        end
      end
    end
  end
end
