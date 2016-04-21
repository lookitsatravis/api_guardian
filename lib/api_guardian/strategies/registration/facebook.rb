
module ApiGuardian
  module Strategies
    module Registration
      class Facebook < Base
        provides_registration_for :facebook

        allowed_api_parameters :access_token, :password, :password_confirmation

        def register(store, attributes)
          super(attributes)

          response = facebook_client(attributes).authorize!

          data = build_user_attributes_from_response(response, attributes)
          identity_data = build_identity_attributes_from_response(response, attributes[:access_token])

          # create user
          instance = store.new(nil)
          user = instance.create_with_identity(data, identity_data, confirm_email: true)

          # TODO: put user created event onto queue

          user
        end

        def build_user_attributes_from_response(response, attributes = {})
          first_name = response['name'].split.first
          last_name = response['name'].split.count > 1 ? response['name'].split[1..-1].join(' ') : ''

          password, password_confirmation = prep_passwords attributes

          {
            first_name: first_name,
            last_name: last_name,
            email: response['email'],
            email_confirmed_at: DateTime.now.utc,
            role_id: ApiGuardian::Stores::RoleStore.default_role.id,
            active: true,
            password: password,
            password_confirmation: password_confirmation
          }
        end

        def build_identity_attributes_from_response(response, access_token)
          {
            provider: 'facebook',
            provider_uid: response['id'],
            tokens: { access_token: access_token }
          }
        end

        protected

        def facebook_client(attributes)
          @facebook_client ||= ApiGuardian::Helpers::Facebook.new(attributes[:access_token])
        end
      end
    end
  end
end
