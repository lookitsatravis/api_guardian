module ApiGuardian
  module Strategies
    module Authentication
      class Facebook < Base
        provides_authentication_for :facebook

        def authenticate(access_token)
          # Get FB user object
          client = ApiGuardian::Helpers::Facebook.new(access_token)
          response = client.authorize!

          # Find user by email
          user = ApiGuardian::Stores::UserStore.new(nil).find_by_email(response['email'])
          return nil unless user

          # Verify identity exists for facebook for this user and that IDs match
          identity = ApiGuardian::Stores::UserStore.find_identity_by_provider(user, :facebook)
          return nil unless identity

          unless identity.provider_uid == response['id']
            fail(
              ApiGuardian::Errors::IdentityAuthorizationFailed,
              'An account was located with your Facebook email, but the Facebook IDs do not match.'
            )
          end

          # Verify user is active (which is all that super does)
          super(user: user)

          update_identity(identity, access_token)

          user
        end

        def update_identity(identity, access_token)
          identity.update_attributes(
            tokens: { access_token: access_token }
          )
        end
      end
    end
  end
end
